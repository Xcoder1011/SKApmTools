//
//  SKANRMonitor.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/24.
//

/*
 
 “N次卡顿超过阈值T”的判定策略:
 一个时间段内卡顿的次数累计大于N时才触发采集和上报
 
 第一种：卡顿阈值T=200ms、卡顿次数N=1，可以判定为单次耗时较长的一次有效卡顿；
 第一种：卡顿阈值T=60ms、卡顿次数N=5，可以判定为频次较多的一次有效卡顿。
 
 */
import Foundation

open class SKANRMonitor: NSObject{
    
    @objc public static let sharedInstance = SKANRMonitor()
    
    fileprivate var observer: CFRunLoopObserver?
    
    fileprivate var activity: CFRunLoopActivity?
    
    fileprivate var semaphore: DispatchSemaphore?
    
    fileprivate var underObserving: Bool = false
    
    // 卡顿次数记录
    fileprivate var count: Int = 0
    
    /// 单次耗时较长的卡顿阈值: 默认值为200ms，单位：毫秒
    @objc public var singleTime: Int = 500
    
    /// 频次较多的卡顿阈值: 默认值为60ms，单位：毫秒
    @objc public var multiTime: Int = 60
    /// 频次较多的卡顿次数: 默认值为5
    @objc public var frequency: Int = 5
    
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
                        let result = semaphore.wait(timeout: DispatchTime.now() + .milliseconds(self.multiTime))
                        if result == .timedOut {
                            if activity == .beforeSources || activity == .afterWaiting {
                                self.count += 1
                                print("！！！！！卡顿了，第\(self.count)次=====>\(activity)")
                                if (self.count == self.frequency) {
                                    print("开始上报卡顿，第\(self.count)次=====>\(activity)")
                                    self.count = 0
                                }
                            }
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
            if let semaphore = SKANRMonitor.sharedInstance.semaphore {
                let count = semaphore.signal()
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

