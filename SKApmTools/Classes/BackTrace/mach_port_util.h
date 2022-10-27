//
//  mach_port_util.h
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

#ifndef mach_port_util_h
#define mach_port_util_h

#include <stdio.h>
#include <mach/mach.h>
#include <dlfcn.h>

/// 获取主线程的标识
mach_port_t get_main_thread_id(void);

/// 解析堆栈符号
bool sk_dladdr(const uintptr_t address, Dl_info* const info);

/// 判读 dli_fname 是否为 NULL
bool sk_has_dli_fname(struct dl_info info);

#endif /* mach_port_util_h */

