#ifndef ali_ai_call_umbrella_h
#define ali_ai_call_umbrella_h

#import <Foundation/Foundation.h>

#if __has_include(<Flutter/Flutter.h>)
#import <Flutter/Flutter.h>
#elif __has_include("Flutter.h")
#import "Flutter.h"
#endif

#if __has_include(<ARTCAICallKit/ARTCAICallKit.h>)
#import <ARTCAICallKit/ARTCAICallKit.h>
#endif

FOUNDATION_EXPORT double ali_ai_callVersionNumber;
FOUNDATION_EXPORT const unsigned char ali_ai_callVersionString[];

#endif /* ali_ai_call_umbrella_h */ 