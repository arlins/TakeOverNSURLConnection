//
//  NSURLProtocolMonitor.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/20.
//  Copyright © 2017. dps All rights reserved.
//

#import "NSURLProtocolMonitor.h"
#import <objc/runtime.h>
#import "NSObject+Debug.h"

@implementation NSURLProtocol (NSURLProtocolMonitor)

+ (void)load
{
    SEL oldSelector = @selector(registerClass:);
    SEL newSelector = @selector(pm_registerClass:);
    
    [self pm_swizzleClassSelector:oldSelector withSelector:newSelector];
}

+ (void)pm_registerClass:(Class)class
{
    PM_LOG(@"NSURLProtocol registerClass: %@", class);
    [self pm_registerClass:class];
}

@end
