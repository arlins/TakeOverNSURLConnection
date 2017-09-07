//
//  TONSURLSessionBlockMaker
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import "TONSURLSessionBlockMaker.h"

@interface TONSURLSessionBlockMaker ()

@end

@implementation TONSURLSessionBlockMaker

- (void)makeGetAction:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( !error )
        {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%s dataString = %@", __PRETTY_FUNCTION__, dataString);
            
            if ( [request.HTTPMethod isEqualToString:@"POST"] )
            {
                NSURL *URL = [self URLFromRespone:dataString];
                [self makeGetAction:URL];
            }
        }
    }];
    
    [task resume];
}

- (void)makePostAction:(NSURL *)URL
{
    NSString *dataString = [self bodyDataString:NSStringFromClass([self class])];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ( !error )
        {
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSLog(@"%s dataString = %@", __PRETTY_FUNCTION__, dataString);
            
            if ( [request.HTTPMethod isEqualToString:@"POST"] )
            {
                NSURL *URL = [self URLFromRespone:dataString];
                [self makeGetAction:URL];
            }
        }
    }];
    
    [task resume];
}

@end
