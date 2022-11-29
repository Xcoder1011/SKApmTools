//
//  SKWrapper.swift
//  SKApmTools
//
//  Created by KUN on 2022/11/28.
//

import Foundation
import UIKit

public struct SKWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol SKWrapperCompatible {}

extension SKWrapperCompatible {
    public var sk: SKWrapper<Self> {
        get { return SKWrapper(self) }
        set { }
    }
}

public enum SKImageFormat {
    case unknow
    case PNG
    case JPEG
    case GIF
    
    struct HeaderData {
        static var PNG: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        static var JPEG_SOI: [UInt8] = [0xFF, 0xD8]
        static var JPEG_IF: [UInt8] = [0xFF]
        static var GIF: [UInt8] = [0x47, 0x49, 0x46]
    }
}

extension Data: SKWrapperCompatible {}

extension SKWrapper where Base == Data {
    var format: SKImageFormat {
        guard base.count > 8 else { return .unknow}
        var buffer = [UInt8](repeating: 0, count: 8)
        base.copyBytes(to: &buffer, count: 8)
        
        if buffer == SKImageFormat.HeaderData.PNG {
            return .PNG
        } else if buffer[0] == SKImageFormat.HeaderData.JPEG_SOI[0],
                  buffer[1] == SKImageFormat.HeaderData.JPEG_SOI[1],
                  buffer[2] == SKImageFormat.HeaderData.JPEG_IF[0] {
            return .JPEG
        } else if buffer[0] == SKImageFormat.HeaderData.GIF[0],
                   buffer[1] == SKImageFormat.HeaderData.GIF[1],
                  buffer[2] == SKImageFormat.HeaderData.GIF[2] {
            return .GIF
        }
        return .unknow
    }
}
