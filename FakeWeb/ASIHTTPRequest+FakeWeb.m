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
    Swizzle(c, @selector(startSynchronous), @selector(override_startSynchronous));
    Swizzle(c, @selector(startAsynchronous), @selector(override_startAsynchronous));
    Swizzle(c, @selector(responseStatusCode), @selector(override_responseStatusCode));
    Swizzle(c, @selector(responseStatusMessage), @selector(override_responseStatusMessage));
    Swizzle(c, @selector(responseString), @selector(override_responseString));
    Swizzle(c, @selector(responseData), @selector(override_responseData));
}

-(void) override_startSynchronous
{
    FakeWebResponder *responder = [FakeWeb responderFor:[self.url absoluteString] method:self.requestMethod];
    if (responder)
        return;
        
    [self override_startSynchronous];
}

-(void) override_startAsynchronous
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
        [self override_startAsynchronous];
    }
}

- (NSInteger)override_responseStatusCode
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder status]
        : [self override_responseStatusCode];
}

- (NSString *)override_responseStatusMessage
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder statusMessage]
        : [self override_responseStatusMessage];
}

- (NSString *)override_responseString
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder body]
        : [self override_responseString];
}

- (NSData *) override_responseData
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [[responder body] dataUsingEncoding:NSUTF8StringEncoding]
        : [self override_responseData];
}

@end
