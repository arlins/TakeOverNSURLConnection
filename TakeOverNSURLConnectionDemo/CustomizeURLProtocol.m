//
//  CustomizeURLProtocol.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/14.
//  Copyright © 2017. dps All rights reserved.
//

#import "CustomizeURLProtocol.h"
#import <ASIHTTPRequest.h>

NSString *const KCustomizeURLProtocolHandledKey = @"KCustomizeURLProtocolHandledKey";

typedef NS_ENUM(NSUInteger, HTTPRequestStyle)
{
    HTTPRequestStyleNSURLConnection,
    HTTPRequestStyleASIHTTPRequest
};

@interface CustomizeURLProtocol ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) ASIHTTPRequest *ASIHTTPRequest;
@property (nonatomic, assign) HTTPRequestStyle httpRequestStyle;

@end

@implementation CustomizeURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    BOOL takeOver = NO;
    
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    if ( ( [scheme caseInsensitiveCompare:@"http"] == NSOrderedSame
          ||[scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ))
    {
        //已经处理过了，防止无限循环
        if (![NSURLProtocol propertyForKey:KCustomizeURLProtocolHandledKey inRequest:request])
        {
            takeOver = YES;
        }
    }
    
    return takeOver;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (instancetype)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    return [super initWithRequest:request cachedResponse:cachedResponse client:client];
}

- (void)startLoading
{
    self.httpRequestStyle = HTTPRequestStyleNSURLConnection;
    [self startLoadingUsingPreferredRequestStyle:self.request];
}

- (void)stopLoading
{
    [self stopASIHTTPRequest];
    [self stopNSHTTPConnection];
}

- (void)startLoadingUsingPreferredRequestStyle:(NSURLRequest *)request
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    
    //标示改request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:KCustomizeURLProtocolHandledKey inRequest:mutableReqeust];
    
    switch ( self.httpRequestStyle )
    {
        case HTTPRequestStyleNSURLConnection:
            [self startNSHTTPConnection:mutableReqeust];
            break;
        case HTTPRequestStyleASIHTTPRequest:
            [self startASIHTTPRequest:mutableReqeust];
            break;
        default:
            break;
    }
}

- (void)startASIHTTPRequest:(NSURLRequest *)request
{
    ASIHTTPRequest *getRequest = [ASIHTTPRequest requestWithURL:request.URL];
    [getRequest setDidReceiveResponseHeadersSelector:@selector(ASIHTTP_request:didReceiveResponseHeaders:)];
    
    self.ASIHTTPRequest = getRequest;
    
    //[getRequest setDidReceiveDataSelector:@selector(ASIHTTP_request:didReceiveDataSelector:)];
    
    [getRequest setDelegate:self];
    [getRequest setRequestMethod:self.request.HTTPMethod];
    [getRequest appendPostData:self.request.HTTPBody];
    [getRequest setDidFinishSelector:@selector(ASIHTTP_getFetchFinished:)];
    [getRequest setDidFailSelector:@selector(ASIHTTP_getFetchFailed:)];
    [getRequest startAsynchronous];
}

- (void)stopASIHTTPRequest
{
    if ( self.ASIHTTPRequest )
    {
        [self.ASIHTTPRequest clearDelegatesAndCancel];
        self.ASIHTTPRequest = nil;
    }
}

- (void)startNSHTTPConnection:(NSURLRequest *)request
{
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:[[NSRunLoop currentRunLoop] currentMode]];
    
    [self.connection start];
}

- (void)stopNSHTTPConnection
{
    if ( self.connection )
    {
        [self.connection cancel];
        self.connection = nil;
    }
}

// NSURLConnection
- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.client URLProtocol:self didLoadData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.client URLProtocol:self didFailWithError:error];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response != nil)
    {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
        [connection cancel];
        
        return nil;
    }
    
    return request;
}

// ASIHTTP
- (void)ASIHTTP_getFetchFailed:(ASIHTTPRequest *)request
{
    [self.client URLProtocol:self didFailWithError:[[NSError alloc] init]];
}

- (void)ASIHTTP_getFetchFinished:(ASIHTTPRequest *)request
{
    [self.client URLProtocol:self didLoadData:[request responseData]];
    [self.client URLProtocolDidFinishLoading:self];
}

//- (void)ASIHTTP_request:(ASIHTTPRequest *)request didReceiveDataSelector:(NSData *)data
//{
//    [self.client URLProtocol:self didLoadData:data];
//}

- (void)ASIHTTP_request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)respone
{
    NSHTTPURLResponse *URLRespone = [[NSHTTPURLResponse alloc] initWithURL:request.url statusCode:request.responseStatusCode HTTPVersion:@"HTTP/1.1" headerFields:respone];

    [self.client URLProtocol:self didReceiveResponse:URLRespone cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

@end
