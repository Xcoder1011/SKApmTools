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

mach_port_t get_main_thread_t(void);

#endif /* mach_port_util_h */
