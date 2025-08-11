//
//  SKANRMonitor.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/24.
//

import Foundation

@objc open class SKANRMonitor: NSObject {
    @objc public static let sharedInstance = SKANRMonitor()
    /// 单次耗时较长的卡顿阈值: 默认值为300ms，单位：毫秒
    @objc public var singleTime: Int = 300
    
    public typealias MonitorCallback = (_ curEntity: SKBacktraceEntity, _ allEntities: [SKBacktraceEntity]) -> Void

    private var observer: CFRunLoopObserver?
    
    private var activity: CFRunLoopActivity?
    
    private var lock = os_unfair_lock()
    
    private var semaphore: DispatchSemaphore?
    
    private var underObserving: Bool = false
    /// 卡顿次数记录
    private var count: Int = 0
    
    @objc public var pendingEntities: [SKBacktraceEntity] = []
    
    private var pendingEntityDict: [String: SKBacktraceEntity] = [:]
    
    private var callback: MonitorCallback?
    
    private var filePath: String? {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first as NSString?
        if let filePath = path?.appendingPathComponent("sk_apm_anr.archive") {
            return filePath
        }
        return nil
    }
    
    override public init() {
        super.init()
        readDataFromDisk()
    }
    
    /// 开启监测
    @objc public class func start() {
        SKANRMonitor.sharedInstance.start()
    }

    /// 停止监测
    @objc public class func stop() {
        SKANRMonitor.sharedInstance.stop()
    }
    
    /// 监测到一个卡顿回调
    @objc public class func monitorCallback(_ callback: @escaping MonitorCallback) {
        SKANRMonitor.sharedInstance.callback = callback
    }
    
    /// 获取卡顿数据
    @objc public class func getPendingEntities() -> [SKBacktraceEntity] {
        return SKANRMonitor.sharedInstance.pendingEntities
    }
    
    /// 清理卡顿数据
    @objc public class func clearPendingEntities() {
        SKANRMonitor.sharedInstance.clearEntities()
    }
}

private extension SKANRMonitor {
    func clearEntities() {
        os_unfair_lock_lock(&lock)
        pendingEntities.removeAll()
        pendingEntityDict.removeAll()
        if let filePath = filePath {
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                } catch {
                    print("SKANRMonitor remove anr data from disk error = \(error.localizedDescription)")
                }
            }
        }
        os_unfair_lock_unlock(&lock)
    }
    
    func start() {
        if self.observer == nil {
            underObserving = true
            semaphore = DispatchSemaphore(value: 1)
            var context = CFRunLoopObserverContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            self.observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, observerCallBack(), &context)
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
            
            Thread.detachNewThread { [self] in
                while underObserving {
                    if let activity = activity, let semaphore = semaphore {
                        let result = semaphore.wait(timeout: DispatchTime.now() + .milliseconds(singleTime))
                        if result == .timedOut {
                            if observer == nil {
                                return
                            }
                            if activity == .beforeSources || activity == .afterWaiting {
                                let entity = SKBackTrace.backTraceInfoEntity(of: Thread.main)
                                handleEntity(entity)
                            }
                        } else {
                            count = 0
                        }
                    }
                }
            }
        }
    }
    
    func handleEntity(_ entity: SKBacktraceEntity) {
        // filter invalid data
        if entity.validFunction == "main" {
            return
        }
        let key = "\(entity.validAddress)_\(entity.validFunction)"
        if !self.pendingEntityDict.keys.contains(key) {
            os_unfair_lock_lock(&lock)
            // limit cache count 50
            if pendingEntities.count >= 50 {
                let removeEntity = pendingEntities.removeLast()
                let removeKey = "\(removeEntity.validAddress)_\(removeEntity.validFunction)"
                self.pendingEntityDict.removeValue(forKey: removeKey)
            }
            self.pendingEntityDict.updateValue(entity, forKey: key)
            self.pendingEntities.insert(entity, at: 0)
            os_unfair_lock_unlock(&lock)
            
            if let filePath = filePath {
                do {
                    print("SKANRMonitor write data to filePath = \(filePath)")
                    let data = try PropertyListEncoder().encode(self.pendingEntities)
                    try data.write(to: URL(fileURLWithPath: filePath))
                } catch {
                    print("SKANRMonitor write data to filePath error = \(error.localizedDescription)")
                }
            }
            
            if let callback = self.callback {
                callback(entity, self.pendingEntities)
            }
        } else {
            print("SKANRMonitor 相同的卡顿只记录一次")
        }
    }
    
    func stop() {
        if self.observer != nil {
            underObserving = false
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, CFRunLoopMode.commonModes)
            self.observer = nil
        }
    }
    
    func observerCallBack() -> CFRunLoopObserverCallBack {
        return { _, activity, _ in
            SKANRMonitor.sharedInstance.activity = activity
            if let semaphore = SKANRMonitor.sharedInstance.semaphore {
                semaphore.signal()
            }
        }
    }
    
    func readDataFromDisk() {
        if let filePath = filePath, FileManager.default.fileExists(atPath: filePath) {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
                let entities = try PropertyListDecoder().decode([SKBacktraceEntity].self, from: data)
                os_unfair_lock_lock(&lock)
                pendingEntities.append(contentsOf: entities)
                for e in entities {
                    let key = "\(e.validAddress)_\(e.validFunction)"
                    pendingEntityDict.updateValue(e, forKey: key)
                }
                os_unfair_lock_unlock(&lock)
            } catch {
                print("SKANRMonitor read data from disk error = \(error.localizedDescription)")
            }
        }
    }
    
    func logActivity(_ activity: CFRunLoopActivity) {
        switch activity {
        case .entry:
            print("即将进入RunLoop")
        case .beforeTimers:
            print("即将处理Timer")
        case .beforeSources:
            print("即将处理Sources")
        case .beforeWaiting:
            print("即将进入休眠")
        case .afterWaiting:
            print("从休眠中唤醒")
        case .exit:
            print("退出RunLoop")
        default:
            break
        }
    }
}
