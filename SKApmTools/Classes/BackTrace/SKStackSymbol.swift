//
//  SKStackSymbol.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

import Foundation

public struct SKStackSymbol: Codable {
    public let symbol: String
    public let file: String
    public let address: UInt
    public let symbolAddress: UInt
    public let image: String
    public let offset: UInt
    public let index: Int
    
    public var demangledSymbol: String {
        return _stdlib_demangleName(symbol)
    }
    
    public var baseAddress: String {
        return image.utf8CString.withUnsafeBufferPointer { (imageBuffer: UnsafeBufferPointer<CChar>) -> String in
            return String(format: "%s", UInt(bitPattern: imageBuffer.baseAddress))
        }
    }
    
    public var formatAddress: String {
#if arch(x86_64) || arch(arm64)
        return String(format: "0x%016llx", address)
#else
        return String(format: "0x%08lx", address)
#endif
    }
    
    public var info: String {
        return image.utf8CString.withUnsafeBufferPointer { (imageBuffer: UnsafeBufferPointer<CChar>) -> String in
            let add = UInt(bitPattern: imageBuffer.baseAddress)
#if arch(x86_64) || arch(arm64)
            return String(format: "%-4ld%-35s 0x%016llx  %@ + %ld \n", index, add, address, demangledSymbol, offset)
#else
            return String(format: "%-4d%-35s 0x%08lx  %@ + %d \n", index, add, address, demangledSymbol, offset)
#endif
        }
    }
}


public struct SKBacktraceEntity: Codable {
    public let threadId: UInt  // 259
    public let validAddress: String // address
    public let validFunction: String // function
    public let traceContent: String
    public let traceSymbols: [SKStackSymbol]
    public let occurenceTime: TimeInterval
}

public struct SKBacktraceEntry: Codable {
    public let `class`: String
    public let name: String
    public let address: UInt
    
    public var log: String {
        return "calss: \(self.class)    name:\(name)   address:\(String(address, radix: 16))\n"
    }
}

@_silgen_name("swift_demangle")
func _stdlib_demangleImpl(
    mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<CChar>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
) -> UnsafeMutablePointer<CChar>?

/// Swift方法名还原
private func _stdlib_demangleName(_ mangledName: String) -> String {
    return mangledName.utf8CString.withUnsafeBufferPointer {
        (mangledNameUTF8CStr) in
        
        let demangledNamePtr = _stdlib_demangleImpl(
            mangledName: mangledNameUTF8CStr.baseAddress,
            mangledNameLength: UInt(mangledNameUTF8CStr.count - 1),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0
        )
        
        if let demangledNamePtr = demangledNamePtr {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return mangledName
    }
}
