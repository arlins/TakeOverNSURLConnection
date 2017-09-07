//
//  TONSURLConnectionMaker
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import "TONSURLConnectionMaker.h"

@interface TONSURLConnectionMaker () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSMutableData *nativeHTTPResponeData;

@end

@implementation TONSURLConnectionMaker

- (void)makeGetAction:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [conn start];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)makePostAction:(NSURL *)URL
{
    NSString *dataString = [self bodyDataString:NSStringFromClass([self class])];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLConnection *conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    [conn start];
    
    NSLog(@"%s %@", __PRETTY_FUNCTION__, dataString);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if ( self.nativeHTTPResponeData == nil )
    {
        self.nativeHTTPResponeData = [NSMutableData data];
    }
    
    [self.nativeHTTPResponeData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *dataString = [[NSString alloc] initWithData:self.nativeHTTPResponeData encoding:NSUTF8StringEncoding];
    
    NSLog(@"%s dataString = %@", __PRETTY_FUNCTION__, dataString);
    
    if ( [connection.currentRequest.HTTPMethod isEqualToString:@"POST"] )
    {
        NSURL *URL = [self URLFromRespone:dataString];
        [self makeGetAction:URL];
    }
    
    self.nativeHTTPResponeData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.nativeHTTPResponeData = nil;
}

@end
