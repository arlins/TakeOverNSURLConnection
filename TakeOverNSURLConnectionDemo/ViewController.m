//
//  ViewController.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/14.
//  Copyright © 2017. dps All rights reserved.
//

#import "ViewController.h"
#import <ASIHTTPRequest.h>
#import <ASIFormDataRequest.h>
#import "TOHTTPRequesMaker.h"
#import "TOASIHTTPRequesMaker.h"
#import "TOASIHTTPRequesMaker.h"
#import "TONSURLSessionMaker.h"
#import "TONSURLSessionBlockMaker.h"

@interface ViewController () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) TOHTTPRequesMaker *requestRunner;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *URL = [NSURL URLWithString:KTOHTTPRequesMakerServerURL];
    
    self.requestRunner = [[TONSURLSessionBlockMaker alloc] init];
    //self.requestRunner = [[TONSURLSessionMaker alloc] init];
    //self.requestRunner = [[TONSURLConnectionMaker alloc] init];
    //self.requestRunner = [[TOASITOHTTPRequesMaker alloc] init];
    [self.requestRunner makePostAction:URL];
    
    //[self loadWebView];
}

- (void)loadWebView
{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    
    [self.view addSubview:webView];
}

@end
