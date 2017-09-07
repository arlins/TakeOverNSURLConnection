//
//  TONSURLSessionMaker
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import "TONSURLSessionMaker.h"

@interface TONSURLSessionMaker () <NSURLSessionDelegate>

@property (nonatomic, strong) NSMutableData *nativeHTTPResponeData;

@end

@implementation TONSURLSessionMaker

- (void)makeGetAction:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"GET";
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    
    [task resume];
}

- (void)makePostAction:(NSURL *)URL
{
    NSString *dataString = [self bodyDataString:NSStringFromClass([self class])];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    
    [task resume];
}



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    if ( self.nativeHTTPResponeData == nil )
    {
        self.nativeHTTPResponeData = [NSMutableData data];
    }
    
    [self.nativeHTTPResponeData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    if ( completionHandler )
    {
        completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    if ( !error )
    {
        NSString *dataString = [[NSString alloc] initWithData:self.nativeHTTPResponeData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%s dataString = %@", __PRETTY_FUNCTION__, dataString);
        
        if ( [task.currentRequest.HTTPMethod isEqualToString:@"POST"] )
        {
            NSURL *URL = [self URLFromRespone:dataString];
            [self makeGetAction:URL];
        }
    }
    
    self.nativeHTTPResponeData = nil;
}

@end
