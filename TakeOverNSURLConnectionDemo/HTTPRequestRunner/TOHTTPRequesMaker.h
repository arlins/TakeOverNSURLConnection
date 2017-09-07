//
//  TOHTTPRequesMaker.h
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/14.
//  Copyright © 2017. dps All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const KTOHTTPRequesMakerServerURL;

@interface TOHTTPRequesMaker : NSObject

- (void)makeGetAction:(NSURL *)URL;
- (void)makePostAction:(NSURL *)URL;

- (NSString *)bodyDataString:(NSString *)from;
- (NSURL *)URLFromRespone:(NSString *)respone;


@end
