//
//  SKImageMonitor.swift
//  SKApmTools
//
//  Created by WDMac on 2022/12/13.
//

import Foundation

@objc open class SKImageMonitor: NSObject {
    
    @objc public static let sharedInstance = SKImageMonitor()
    
    @objc public private(set) var enable: Bool = false
    
    @objc public class func start() {
        SKImageMonitor.sharedInstance.enable = true
        UIImageView.initializeOnceSwift()
    }
    
    @objc public class func stop() {
        SKImageMonitor.sharedInstance.enable = false
    }
}
