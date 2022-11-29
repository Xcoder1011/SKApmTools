//
//  DispatchQueue+onceTrack.swift
//  SKApmTools
//
//  Created by KUN on 2022/11/28.
//

import Foundation

extension DispatchQueue {
    private static var onceTracker = [String]()
    
    public class func sk_once(_ token: String, _ block:() -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}

extension NSObject {
    internal static func sk_swizzleMethod(_ aClass: AnyClass, _ originSelector: Selector, _ swizzledSelector: Selector) {
        guard let originMethod = class_getInstanceMethod(aClass, originSelector), let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector) else {
            return
        }
        let swizzledImp = method_getImplementation(swizzledMethod)
        let didAddSuccess = class_addMethod(aClass, originSelector, swizzledImp, method_getTypeEncoding(swizzledMethod))
        
        if didAddSuccess {
            let originImp = method_getImplementation(originMethod)
            class_replaceMethod(aClass, swizzledSelector, originImp, method_getTypeEncoding(originMethod))
            
        } else {
            method_exchangeImplementations(originMethod, swizzledMethod)
        }
    }
}

