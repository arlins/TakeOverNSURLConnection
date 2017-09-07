//
//  NSURLSessionProtocolMonitor.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/20.
//  Copyright © 2017. dps All rights reserved.
//

#import "NSURLSessionProtocolMonitor.h"
#import <objc/runtime.h>
#import "NSObject+Debug.h"

NSString *const KProtocolClassesKeyPath = @"protocolClasses";

@implementation NSObject (NSURLSessionProtocolMonitor)

+ (void)load
{
    {
        SEL oldSelector = @selector(init);
        SEL newSelector = @selector(pm_init);
        [self pm_swizzleInstanceSelector:oldSelector withSelector:newSelector];
    }
    
    {
        SEL oldSelector = NSSelectorFromString(@"dealloc");
        SEL newSelector = NSSelectorFromString(@"pm_dealloc");
        [self pm_swizzleInstanceSelector:oldSelector withSelector:newSelector];
    }
}

- (void)pm_dealloc
{
    if ( [self isKindOfClass:[NSURLSessionConfiguration class]] )
    {
        [self removeObserver:self forKeyPath:KProtocolClassesKeyPath context:nil];
    }
    
    [self pm_dealloc];
}

- (instancetype)pm_init
{
    if ( [self isKindOfClass:[NSURLSessionConfiguration class]] )
    {
        [self addObserver:self forKeyPath:KProtocolClassesKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return [self pm_init];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ( [keyPath isEqualToString:KProtocolClassesKeyPath]
        && [self isKindOfClass:[NSURLSessionConfiguration class]] )
    {
        NSArray<Class> *internalProtocolClasses = @[NSClassFromString(@"_NSURLHTTPProtocol"),
                                                       NSClassFromString(@"_NSURLDataProtocol"),
                                                       NSClassFromString(@"_NSURLFTPProtocol"),
                                                       NSClassFromString(@"_NSURLFileProtocol"),
                                                       NSClassFromString(@"NSAboutURLProtocol")];
        
        NSArray<Class> *protocolClasses = change[NSKeyValueChangeNewKey];
        
        __block BOOL hasCustomizeProtocolClasses = NO;
        [protocolClasses enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isInternalProtocolClass = NO;
            for ( int i = 0; i < internalProtocolClasses.count; i++ )
            {
                Class internalClass = [internalProtocolClasses objectAtIndex:i];
                if ( internalClass == obj )
                {
                    isInternalProtocolClass = YES;
                    break;
                }
            }
            
            if ( !isInternalProtocolClass )
            {
                hasCustomizeProtocolClasses = YES;
                *stop = YES;
            }
        }];
        
        if ( hasCustomizeProtocolClasses )
        {
            PM_LOG(@"NSURLSessionConfiguration protocolClasses change: %@", protocolClasses );
        }
    }
}

@end
