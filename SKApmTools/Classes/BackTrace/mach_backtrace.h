// https://github.com/Sharalink/catchCrashInfoWithSuspendAllThread/blob/c5e44925468d50b478e831578d6b53e5440dd8b5/MachThreadBacktrace.c

#ifndef mach_backtrace_h
#define mach_backtrace_h

#include <mach/mach.h>

#include <dlfcn.h>
#include <pthread.h>
#include <sys/types.h>
#include <limits.h>
#include <string.h>
#include <mach-o/dyld.h>
#include <mach-o/nlist.h>

/**
 *  fill a backtrace call stack array of given thread
 *
 *  @param thread   mach thread for tracing
 *  @param stack    caller space for saving stack trace info
 *  @param maxSymbols max stack array count
 *
 *  @return call stack address array
 */
int mach_backtrace(thread_t thread, void** stack, int maxSymbols);

#endif /* mach_backtrace_h */
