//
//  SKANRMonitor.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/24.
//

import Foundation

open class SKANRMonitor: NSObject{
    
    @objc public static let sharedInstance = SKANRMonitor()
    /// 单次耗时较长的卡顿阈值: 默认值为500ms，单位：毫秒
    @objc public var singleTime: Int = 500
    
    fileprivate var observer: CFRunLoopObserver?
    
    fileprivate var activity: CFRunLoopActivity?
    
    fileprivate var semaphore: DispatchSemaphore?
    
    fileprivate var underObserving: Bool = false
    /// 卡顿次数记录
    fileprivate var count: Int = 0
    
    fileprivate var pendingEntitys: [SKBacktraceEntity] = []
    
    fileprivate var pendingEntityDict: [String: SKBacktraceEntity] = [:]
    
    @objc public func start() {
        if nil == self.observer {
            underObserving = true
            semaphore = DispatchSemaphore(value: 1)
            var context = CFRunLoopObserverContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
            self.observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.allActivities.rawValue, true, 0, observerCallBack(), &context)
            CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
            
            Thread.detachNewThread {
                while(self.underObserving) {
                    if let activity = self.activity, let semaphore = self.semaphore {
                        SKANRMonitor.sharedInstance.logActivity(activity)
                        let result = semaphore.wait(timeout: DispatchTime.now() + .milliseconds(self.singleTime))
                        if result == .timedOut {
                            if self.observer == nil {
                                return
                            }
                            if activity == .beforeSources || activity == .afterWaiting {
                                print("监测到卡顿")
                                let entity = SKBackTrace.backTraceInfoEntity(of: Thread.main)
                                let key = "\(entity.validAddress)_\(entity.validFunction)"
                                if !self.pendingEntityDict.keys.contains(key) {
                                    self.pendingEntityDict.updateValue(entity, forKey: key)
                                    self.pendingEntitys.append(entity)
                                    print(entity.threadId)
                                    print(entity.validAddress)
                                    print(entity.validFunction)
                                    print(entity.traceContent)
                                } else {
                                    print("相同的卡顿只记录一次")
                                }
                            }
                        } else {
                            self.count = 0
                        }
                    }
                }
            }
        }
    }
    
    @objc public func stop() {
        if nil != self.observer  {
            underObserving = false
            CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, CFRunLoopMode.commonModes)
            self.observer = nil
        }
    }
    
    fileprivate func observerCallBack() -> CFRunLoopObserverCallBack {
        return {(observer, activity, pointer) in
            SKANRMonitor.sharedInstance.activity = activity
            print("即将进入RunLoop")
            if let semaphore = SKANRMonitor.sharedInstance.semaphore {
                semaphore.signal()
            }
        }
    }
    
    fileprivate func logActivity(_ activity: CFRunLoopActivity) {
        switch activity {
        case .entry:
            print("即将进入RunLoop")
            break
        case .beforeTimers:
            print("即将处理Timer")
            break
        case .beforeSources:
            print("即将处理Sources")
            break
        case .beforeWaiting:
            print("即将进入休眠")
            break
        case .afterWaiting:
            print("从休眠中唤醒")
            break
        case .exit:
            print("退出RunLoop")
            break
        default:
            break
        }
    }
}

