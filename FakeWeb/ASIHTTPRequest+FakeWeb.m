//
//  ASIHTTPRequest+FakeWeb.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 5/15/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "ASIHTTPRequest+FakeWeb.h"
#import "FakeWeb+Private.h"

@implementation ASIHTTPRequest (FakeWeb)

+ (void)load
{
    Class c = [ASIHTTPRequest class];
    Swizzle(c, @selector(startSynchronous), @selector(overrideStartSynchronous));
    Swizzle(c, @selector(startAsynchronous), @selector(overrideStartAsynchronous));
    Swizzle(c, @selector(responseStatusCode), @selector(overrideResponseStatusCode));
    Swizzle(c, @selector(responseStatusMessage), @selector(overrideResponseStatusMessage));
    Swizzle(c, @selector(responseString), @selector(overrideResponseString));
    Swizzle(c, @selector(responseData), @selector(overrideResponseData));
}

-(void) overrideStartSynchronous
{
    FakeWebResponder *responder = [FakeWeb responderFor:[self.url absoluteString] method:self.requestMethod];
    if (responder)
        return;
        
    [self overrideStartSynchronous];
}

-(void) overrideStartAsynchronous
{
    FakeWebResponder __block *responder = [FakeWeb responderFor:[self.url absoluteString] method:self.requestMethod];
    [FakeWeb setMatchingResponder:nil];
    if (responder)
    {
        double delayInSeconds = 0.001;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [FakeWeb setMatchingResponder:responder];
        });
    }
    else 
    {
        [self overrideStartAsynchronous];
    }
}

- (NSInteger)overrideResponseStatusCode 
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder status]
        : [self overrideResponseStatusCode];
}

- (NSString *)overrideResponseStatusMessage
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder statusMessage]
        : [self responseStatusMessage];
}

- (NSString *)overrideResponseString
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder body]
        : [self overrideResponseString];
}

- (NSData *) overrideResponseData 
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [[responder body] dataUsingEncoding:NSUTF8StringEncoding]
        : [self overrideResponseData];
}

@end
