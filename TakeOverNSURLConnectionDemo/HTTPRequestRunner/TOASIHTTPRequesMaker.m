//
//  TOASITOHTTPRequesMaker
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/17.
//  Copyright © 2017. dps All rights reserved.
//

#import "TOASIHTTPRequesMaker.h"
#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>

@implementation TOASITOHTTPRequesMaker

- (void)ASIHTTP_getFetchFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [request error]);
}

- (void)ASIHTTP_getFetchFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [request responseString]);
}

- (void)ASIHTTP_uploadFailed:(ASIHTTPRequest *)request
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [request error]);
}

- (void)ASIHTTP_uploadFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, [request responseString]);
    
    NSString *respone = [request responseString];
    NSURL *URL = [self URLFromRespone:respone];
    [self makeGetAction:URL];
}

- (void)makeGetAction:(NSURL *)URL
{
    // GET
    ASIHTTPRequest *getRequest = [ASIHTTPRequest requestWithURL:URL];
    [getRequest setDelegate:self];
    [getRequest setDidFinishSelector:@selector(ASIHTTP_getFetchFinished:)];
    [getRequest setDidFailSelector:@selector(ASIHTTP_getFetchFailed:)];
    [getRequest startAsynchronous];
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)makePostAction:(NSURL *)URL
{
    // POST
    ASIHTTPRequest *postRequest = [ASIHTTPRequest requestWithURL:URL];
    [postRequest setTimeOutSeconds:20];
    
    [postRequest setShouldContinueWhenAppEntersBackground:YES];
    [postRequest setDelegate:self];
    [postRequest setDidFailSelector:@selector(ASIHTTP_uploadFailed:)];
    [postRequest setDidFinishSelector:@selector(ASIHTTP_uploadFinished:)];
    
    NSString *dataString = [self bodyDataString:NSStringFromClass([self class])];
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest appendPostData:data];
    
    [postRequest startAsynchronous];
    
    NSLog(@"%s %@", __PRETTY_FUNCTION__, dataString);
}

@end
