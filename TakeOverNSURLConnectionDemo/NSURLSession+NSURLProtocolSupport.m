//
//  NSURLSession+NSURLProtocolSupport.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import "NSURLSession+NSURLProtocolSupport.h"
#import <objc/runtime.h>

static NSMutableArray<Class> * g_sessionProtocolClasses = nil;

@implementation NSURLSession (NSURLProtocolSupport)

+ (void)ps_swizzleClassSelector:(SEL)originalSelector withSEL:(SEL)swizzledSelector {
    Class class = [self class];
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    if ( originalMethod != NULL && swizzledMethod != NULL )
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

+ (NSURLSession *)ps_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration
{
    [self ps_addProtocolClassToConfiguration:configuration];
    
    return [self ps_sessionWithConfiguration:configuration];
}

+ (NSURLSession *)ps_sessionWithConfiguration:(NSURLSessionConfiguration *)configuration delegate:(nullable id <NSURLSessionDelegate>)delegate delegateQueue:(nullable NSOperationQueue *)queue
{
    [self ps_addProtocolClassToConfiguration:configuration];
    
    return [self ps_sessionWithConfiguration:configuration delegate:delegate delegateQueue:queue];
}

+ (void)ps_hookCreateSessionMethods
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL oldSelector = @selector(sessionWithConfiguration:);
        SEL newSelector = @selector(ps_sessionWithConfiguration:);
        [self ps_swizzleClassSelector:oldSelector withSEL:newSelector];
        
        oldSelector = @selector(sessionWithConfiguration:delegate:delegateQueue:);
        newSelector = @selector(ps_sessionWithConfiguration:delegate:delegateQueue:);
        [self ps_swizzleClassSelector:oldSelector withSEL:newSelector];
    });
}

+ (void)performBlockOnMainThread:(void(^)())block
{
    if ( block == nil )
    {
        return;
    }
    
    if ( ![NSThread isMainThread] )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
    else
    {
        block();
    }
}

+ (BOOL)ps_registerProtocolClass:(Class)protocolClass
{
    if ( ![protocolClass isSubclassOfClass:[NSURLProtocol class]] )
    {
        assert(0);
        return NO;
    }
    
    if ( ![g_sessionProtocolClasses containsObject:protocolClass] )
    {
        [self performBlockOnMainThread:^{
            [self ps_internalRegisterProtocolClass:protocolClass];
        }];
    }
    
    return YES;
}

+ (BOOL)ps_unregisterProtocolClass:(Class)protocolClass
{
    if ( ![protocolClass isSubclassOfClass:[NSURLProtocol class]] )
    {
        assert(0);
        return NO;
    }
    
    [self performBlockOnMainThread:^{
        [self ps_internalUnregisterProtocolClass:protocolClass];
    }];
    
    return YES;
}

+ (void)ps_internalRegisterProtocolClass:(Class)protocolClass
{
    [self ps_hookCreateSessionMethods];
    
    if (g_sessionProtocolClasses == nil)
    {
        g_sessionProtocolClasses = [[NSMutableArray alloc] init];
    }
    
    [g_sessionProtocolClasses addObject:protocolClass];
}

+ (void)ps_internalUnregisterProtocolClass:(Class)protocolClass
{
    if ( g_sessionProtocolClasses )
    {
        [g_sessionProtocolClasses removeObject:protocolClass];
    }
}

+ (void)ps_addProtocolClassToConfiguration:(NSURLSessionConfiguration *)configuration
{
    if ( g_sessionProtocolClasses == nil || configuration == nil )
    {
        return;
    }
    
    NSArray<Class> *defaultProtocolClasses = configuration.protocolClasses;
    NSMutableArray<Class> *allProtocolClasses = [NSMutableArray array];
    
    // Note that protocol class in front of protocolClasses will be called by URL loading system first.
    // Add customize url protocol classes.
    [g_sessionProtocolClasses enumerateObjectsUsingBlock:^(Class  _Nonnull objClass, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL findClass = [defaultProtocolClasses containsObject:objClass];
        if ( !findClass )
        {
            [allProtocolClasses addObject:objClass];
        }
    }];
    
    // Add default url protocol classes.
    if ( defaultProtocolClasses != nil && defaultProtocolClasses.count > 0 )
    {
        [allProtocolClasses addObjectsFromArray:defaultProtocolClasses];
    }
    
    configuration.protocolClasses = allProtocolClasses;
}

@end
