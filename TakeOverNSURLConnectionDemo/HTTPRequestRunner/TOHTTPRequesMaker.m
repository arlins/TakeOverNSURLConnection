//
//  TOHTTPRequesMaker.m
//  TakeOverNSURLConnectionDemo
//
//  Created by arlin on 2016/8/14.
//  Copyright © 2017. dps All rights reserved.
//

#import "TOHTTPRequesMaker.h"

NSString *const KTOHTTPRequesMakerServerURL = @"http://posttestserver.com/post.php";

@interface TOHTTPRequesMaker ()

@end

@implementation TOHTTPRequesMaker

- (NSString *)bodyDataString:(NSString *)from
{
    return [NSString stringWithFormat:@"from=%@&date=%lld", from, (long long)[NSDate date].timeIntervalSince1970];
}

- (NSURL *)URLFromRespone:(NSString *)respone
{
    // respone:
    // Successfully dumped 0 post variables.
    // View it at http://www.posttestserver.com/data/2017/07/14/06.46.392067098787
    // No Post body.
    
    NSRange startRange = [respone rangeOfString:@"http://"];
    NSRange endRange = [respone rangeOfString:@"No Post body"];
    NSString *URL = [respone substringWithRange:NSMakeRange(startRange.location, endRange.location - startRange.location - 1)];
    
    return [NSURL URLWithString:URL];
}

- (void)makeGetAction:(NSURL *)URL
{
    assert(0);
}

- (void)makePostAction:(NSURL *)URL
{
    assert(0);
}

@end
