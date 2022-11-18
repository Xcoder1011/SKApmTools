//
//  SKDynamicSymbolParser.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

import Foundation

/// ASLR
public private(set) var _appASLR : Int = 0

/// 根据 Mach-O 符号表 解析符号
func mach_O_parseSymbol(with addr: UnsafeMutableRawPointer, index: Int) -> SKStackSymbol {
    var info = dl_info()
    let address = UInt(bitPattern: addr)
    // sk_dladdr(address, &info)
    dladdr(addr, &info)
    
    return SKStackSymbol(symbol: _symbol(info: info),
                       file: _dli_fname(with: info),
                       address: address,
                       symbolAddress: unsafeBitCast(info.dli_saddr, to: UInt.self),
                       image: _image(info: info),
                       offset: _offset(info: info, address: address),
                       index: index)
}

/// the symbol nearest the address
private func _symbol(info: dl_info) -> String {
    if
        let dli_sname = info.dli_sname,
        let sname = String(validatingUTF8: dli_sname) {
        return sname
    }
    else if
        let dli_fname = info.dli_fname,
        let _ = String(validatingUTF8: dli_fname) {
        return _image(info: info)
    }
    else {
        return String(format: "0x%1x", UInt(bitPattern: info.dli_saddr))
    }
}

/// thanks to https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlAddressInfo.swift
/// the "image" (shared object pathname) for the instruction
private func _image(info: dl_info) -> String {
    guard
        let dli_fname = info.dli_fname,
        let fname = String(validatingUTF8: dli_fname),
        let _ = fname.range(of: "/", options: .backwards, range: nil, locale: nil)
    else {
        return "???"
    }
    
    return (fname as NSString).lastPathComponent
}

/// the address' offset relative to the nearest symbol
private func _offset(info: dl_info, address: UInt) -> UInt {
    if
        let dli_sname = info.dli_sname,
        let _ = String(validatingUTF8: dli_sname) {
        return address - UInt(bitPattern: info.dli_saddr)
    }
    else if
        let dli_fname = info.dli_fname,
        let _ = String(validatingUTF8: dli_fname) {
        return address - UInt(bitPattern: info.dli_fbase)
    }
    else {
        return address - UInt(bitPattern: info.dli_saddr)
    }
}

private func _dli_fname(with info: dl_info) -> String {
    if sk_has_dli_fname(info) {
        return String(cString: info.dli_fname)
    }
    else {
        return "-"
    }
}
                       

