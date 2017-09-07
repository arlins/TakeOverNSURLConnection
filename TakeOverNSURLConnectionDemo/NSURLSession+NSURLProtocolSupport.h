//
//  NSURLSession+NSURLProtocolSupport.h
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (NSURLProtocolSupport)

/**
@method
@abstract Register protocol for all customize NSURLSession instances.
@discussion Custom NSURLProtocol subclass only work when using NSURLConnection Or
 [NSURLSession sharedSession] For the protocol to work in other sessions, it must be
 listed (via the NSURLSessionConfiguration.protocolClasses property) in the configuration used to 
 create the session.
 Using NSURLSession (NSURLProtocolSupport) to make Custom NSURLProtocol subclass work not only in the shared session.
 Note that NSURLSession (NSURLProtocolSupport) is not thread-safe, it can only be called on mian thread.
@param protocolClass subclass of NSURLProtocol
@return YES if the registration is successful, NO otherwise. The failure condition is if protocolClass is not a subclass of NSURLProtocol.
*/
+ (BOOL)ps_registerProtocolClass:(Class)protocolClass;

/**
 @method
 @abstract unregister protocol for all customize NSURLSession instances.
 @param protocolClass subclass of NSURLProtocol
 @return YES if the unregistration is successful, NO otherwise. The failure condition is if protocolClass is not a subclass of NSURLProtocol.
 */
+ (BOOL)ps_unregisterProtocolClass:(Class)protocolClass;

@end
