#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "mach_backtrace.h"
#import "mach_port_util.h"

FOUNDATION_EXPORT double SKApmToolsVersionNumber;
FOUNDATION_EXPORT const unsigned char SKApmToolsVersionString[];

