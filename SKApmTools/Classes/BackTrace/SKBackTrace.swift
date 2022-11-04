//
//  SKBackTrace.swift
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

import Foundation
import MachO

public class SKBackTrace {
    
    /// 获取指定线程的堆栈信息
    public static func backTraceInfoEntity(of thread: Thread) -> SKBacktraceEntity {
        let mach_thread = _machThread(from: thread)
        let stackSize : UInt32 = 128
        let addrs = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(stackSize))
        defer { addrs.deallocate() }
        let frameCount = mach_back_trace(mach_thread, stack: addrs, maxSymbols: Int32(stackSize))
        let buf = UnsafeBufferPointer(start: addrs, count: Int(frameCount))
        var validAddress = "", validFunction = "", traceContent = ""
        var symbols : [SKStackSymbol] = []
        let bundleName = Bundle.main.infoDictionary?["CFBundleName"] // like SKApmTools_Example
        /// 解析堆栈地址
        for (index, addr) in buf.enumerated() {
            guard let addr = addr else { continue }
            let address = UInt(bitPattern: addr)
            let symbol = mach_O_parseSymbol(with: address, index: index)
            traceContent.append("\(symbol.info)")
            symbols.append(symbol)
            if let bundleName = bundleName, validAddress.count == 0,  bundleName as! String == symbol.baseAddress {
                validAddress = symbol.formatAddress
                validFunction = symbol.demangledSymbol
            }
        }
        if validAddress.count == 0 {
            validAddress = symbols.first?.formatAddress ?? ""
            validFunction = symbols.first?.demangledSymbol ?? ""
        }
        let time = Date.timeIntervalSinceReferenceDate
        let entity = SKBacktraceEntity(threadId: UInt(mach_thread), validAddress: validAddress, validFunction: validFunction, traceContent: traceContent, traceSymbols: symbols, occurenceTime: time)
        return entity
    }
    
    /// 获取线程对应的线程标识
    private static func _machThread(from thread: Thread) -> thread_t {
        guard let (threads, count) = _machAllThread() else {
            return mach_thread_self()
        }
        
        /// 判断目标 thread, 如果是主线程，直接返回对应标识
        if thread.isMainThread {
            return get_main_thread_id()
        }
        
        var name : [Int8] = []
        let originName = thread.name
        
        for i in 0 ..< count {
            let index = Int(i)
            /// NSThread 取到的 name 和 pthread name 是一致的
            /// 遍历 threads，通过 pthread_from_mach_thread_np 逐个获取 name 进行比对
            /// 匹配则返回 NSThread 对应的线程标识
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
        /// 进程 ID
        let mach_task = mach_task_self_
        
        /// 通过 task_threads 获取当前进程中线程列表 thread_act_array_t
        guard task_threads(mach_task, &(thread_array), &number_t) == KERN_SUCCESS else {
            return nil
        }
        
        return (thread_array!, number_t)
    }
    
}

@_silgen_name("mach_backtrace")
public func mach_back_trace(_ thread: thread_t,
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
