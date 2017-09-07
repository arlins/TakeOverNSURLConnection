//
//  NSObjectDebug.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/20.
//  Copyright © 2017. dps All rights reserved.
//

#import "NSObject+Debug.h"
#import <objc/runtime.h>

@implementation NSObject (Debug)

+ (void)pm_printObjectDescription
{
    Class clazz = [self class];
    u_int count = -1;
    
    //Describes the instance variables declared by a class.
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        //Returns the name of an instance variable.
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    //Describes the properties declared by a class.
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        //A C string containing the property's name
        const char* propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    //Describes the instance methods implemented by a class.
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        //Returns the name of a method.
        SEL selector = method_getName(methods[i]);
        //Returns the name of the method specified by a given selector.
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    PM_LOG(@"%@", classDump);
}

+ (void)pm_swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)pm_swizzleInstanceSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
