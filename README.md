## TakeOverNSURLConnection
Show how to take over `URL loading system` on iOS 

## What is this
Sometime we need to take over all the network requests in the whole app in some cases, it is clear that we can use customize `NSURLProtocol` to make all network requests go though our protocol, but there are still some problems.

Requests maked by low-level api, such as `ASIHTTPRequest`(actually is CFStream), `CFStream/CFSocket`, it is not dispatched to `URL loading system`,we need another way to take over thoes requests.

Let's see how to take over all the network requests which are dispatched to `URL loading system`

## How to take over URL loading system
As we know,requests which are dispatched to `URL loading system` using `NSURLConnection` or `NSURLSession` can be sent to customize protocol,if we register our protocol to `NSURLProtocol`.

1: Requests maked by `NSURLConnection` or `+[NSURLSession sharedInstance]` are explicit that it will be dispatched to subclass of `NSURLProtocol` if we has already registered it into `NSURLProtocol`

2: Requests maked by other `NSURLSession` instances which are not default session(via `+[NSURLSession sharedSession]`), will not be sent to customize protocol.To make thoes requests work like requests maked by `+[NSURLSession sharedInstance]`, we need to set customize protocol into `protocolClasses` of `NSURLSessionConfiguration`.

```objc
NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

// Set protocolClasses so that the request can be sent to CustomizeURLProtocol
sessionConfig.protocolClasses = @[[CustomizeURLProtocol class]];

NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       // Do something...
}];
    
[task resume];
```

The demo show you how to take over all http/https requests maked by `NSURLConnection` or `NSURLSession`

## Notes
1:It is important that when we make a post request using `NSURLSession`, the `HTTPBody` we set in `NSURLRequest` will be coverted into `HTTPBodyStream`. when we get the dispatched request in protocol, `HTTPBody` will be nil, the real body content is in `HTTPBodyStream`

## Learn More
1:https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/WorkingWithHTTPAndHTTPSRequests/WorkingWithHTTPAndHTTPSRequests.html

2:https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i

3:http://nshipster.com/nsurlprotocol/

4:https://stackoverflow.com/questions/18388633/nsurlrequest-with-app-level-proxyhost-proxyport-settings

5:https://stackoverflow.com/questions/28101582/how-to-programmatically-add-a-proxy-to-an-nsurlsession

6:http://www.mail-archive.com/cocoa-dev@lists.apple.com/msg21050.html

7:https://stackoverflow.com/questions/36555018/why-is-the-httpbody-of-a-request-inside-an-nsurlprotocol-subclass-always-nil

8:https://bugs.webkit.org/show_bug.cgi?id=137299

