//
//  SKStackTrace.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

import Foundation
import MachO

public class SKStackTrace {
    
    /// 获取指定线程的堆栈信息
    public static func stackTrace(of thread: Thread) -> [SKStackSymbol] {
        let mach_thread = _machThread(from: thread)
        var symbols : [SKStackSymbol] = []
        let stackSize : UInt32 = 128
        let addrs = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(stackSize))
        defer { addrs.deallocate() }
        let frameCount = mach_stack_trace(mach_thread, stack: addrs, maxSymbols: Int32(stackSize))
        let buf = UnsafeBufferPointer(start: addrs, count: Int(frameCount))
        
        for (index, addr) in buf.enumerated() {
            guard let addr = addr else { continue }
            let address = UInt(bitPattern: addr)
            let symbol = SKStackSymbol(symbol: "not symbol",
                                       file: "",
                                       address: address,
                                       symbolAddress: 0,
                                       image: "dylib",
                                       offset: 0,
                                       index: index)
            symbols.append(symbol)
        }
        return symbols
    }
    
    /// Thread to mach thread
    private static func _machThread(from thread: Thread) -> thread_t {
        guard let (threads, count) = _machAllThread() else {
            return mach_thread_self()
        }
        
        if thread.isMainThread {
            return get_main_thread_t()
        }
        
        var name : [Int8] = []
        let originName = thread.name
        
        for i in 0 ..< count {
            let index = Int(i)
            if let p_thread = pthread_from_mach_thread_np((threads[index])) {
                name.append(Int8(Character("\0").ascii ?? 0))
                pthread_getname_np(p_thread, &name, MemoryLayout<Int8>.size * 256)
                if (strcmp(&name, (thread.name!.ascii)) == 0) {
                    thread.name = originName
                    return threads[index]
                }
            }
        }
        
        thread.name = originName
        return mach_thread_self()
    }
    
    /// get all thread
    private static func _machAllThread() -> (thread_act_array_t, mach_msg_type_number_t)? {
        var thread_array : thread_act_array_t?
        var number_t : mach_msg_type_number_t = 0
        let mach_task = mach_task_self_
        
        guard task_threads(mach_task, &(thread_array), &number_t) == KERN_SUCCESS else {
            return nil
        }
        
        return (thread_array!, number_t)
    }
    
}

@_silgen_name("mach_backtrace")
public func mach_stack_trace(_ thread: thread_t,
                             stack: UnsafeMutablePointer<UnsafeMutableRawPointer?>,
                             maxSymbols: Int32) -> Int32

extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension String {
    var ascii : [Int8] {
        var unicodeValues = [Int8]()
        for code in unicodeScalars {
            unicodeValues.append(Int8(code.value))
        }
        return unicodeValues
    }
}
