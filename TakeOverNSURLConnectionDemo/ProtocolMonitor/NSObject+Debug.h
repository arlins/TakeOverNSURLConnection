//
//  NSObjectDebug.h
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/20.
//  Copyright © 2017. dps All rights reserved.
//

#import <Foundation/Foundation.h>

#define PM_LOG(frmt, ...) NSLog((@"[PM] " frmt), ##__VA_ARGS__);

@interface NSObject (Debug)

+ (void)pm_printObjectDescription;
+ (void)pm_swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;
+ (void)pm_swizzleInstanceSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;

@end
