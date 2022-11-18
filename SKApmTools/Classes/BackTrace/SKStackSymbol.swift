//
//  SKStackSymbol.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

import Foundation

@objc public class SKStackSymbol: NSObject, Codable {
    @objc public var symbol: String
    @objc public var file: String
    @objc public var address: UInt
    @objc public var symbolAddress: UInt
    @objc public var image: String
    @objc public var offset: UInt
    @objc public var index: Int
    
    @objc public var demangledSymbol: String {
        return _stdlib_demangleName(symbol)
    }
    
    @objc public var module: String {
        return image.utf8CString.withUnsafeBufferPointer { (imageBuffer: UnsafeBufferPointer<CChar>) -> String in
            return String(format: "%s", UInt(bitPattern: imageBuffer.baseAddress))
        }
    }
    
    @objc public var formatAddress: String {
#if arch(x86_64) || arch(arm64)
        return String(format: "0x%016llx", address)
#else
        return String(format: "0x%08lx", address)
#endif
    }
    
    @objc public var info: String {
        return image.utf8CString.withUnsafeBufferPointer { (imageBuffer: UnsafeBufferPointer<CChar>) -> String in
            let module = UInt(bitPattern: imageBuffer.baseAddress)
#if arch(x86_64) || arch(arm64)
            return String(format: "%-4ld%-35s 0x%016llx  %@ + %ld \n", index, module, address, demangledSymbol, offset)
#else
            return String(format: "%-4d%-35s 0x%08lx  %@ + %d \n", index, module, address, demangledSymbol, offset)
#endif
        }
    }
    
    init(symbol: String, file: String, address: UInt, symbolAddress: UInt, image: String, offset: UInt, index: Int) {
        self.symbol = symbol
        self.file = file
        self.address = address
        self.symbolAddress = symbolAddress
        self.image = image
        self.offset = offset
        self.index = index
    }
}

@objc public class SKBacktraceEntity: NSObject, Codable {
    @objc public var threadId: UInt  // 259
    @objc public var validAddress: String // address
    @objc public var validFunction: String // function
    @objc public var traceContent: String
    @objc public var traceSymbols: [SKStackSymbol]
    @objc public var occurenceTime: TimeInterval
    
    init(threadId: UInt, validAddress: String, validFunction: String, traceContent: String, traceSymbols: [SKStackSymbol], occurenceTime: TimeInterval) {
        self.threadId = threadId
        self.validAddress = validAddress
        self.validFunction = validFunction
        self.traceContent = traceContent
        self.traceSymbols = traceSymbols
        self.occurenceTime = occurenceTime
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
