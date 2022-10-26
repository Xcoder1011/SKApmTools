//
//  mach_port_util.c
//  SKApmTools
//
//  Created by KUN on 2022/10/26.
//

#include "mach_port_util.h"

static mach_port_t _mach_main_thread_t;

__attribute__((constructor)) static
void _setup_main_thread() {
    _mach_main_thread_t = mach_thread_self();
}

mach_port_t get_main_thread_t() {
    return _mach_main_thread_t;
}
