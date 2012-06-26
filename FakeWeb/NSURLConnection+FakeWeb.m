//
//  NSURLConnection+FakeWeb.m
//  FakeWeb
//
//  Created by dealforest on 12/06/25.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "NSURLConnection+FakeWeb.h"
#import "FakeWeb+Private.h"

@implementation NSURLConnection (FakeWeb)

+ (void)load
{
    Class c = [self class];
    SwizzleClassMethod(c, @selector(sendSynchronousRequest:returningResponse:error:), @selector(overrideSendSynchronousRequest:returningResponse:error:));
}

+ (NSHTTPURLResponse *)createDummyResponse:(NSURLRequest *)request responder:(FakeWebResponder *)responder
{
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"text/plain; charset=UTF-8", @"Content-Type",
                             [NSString stringWithFormat:@"%d", [[responder body] length]], @"Content-Length",
                             nil];
    return [[NSHTTPURLResponse alloc] initWithURL:[request URL]
                                       statusCode:[responder status]
                                      HTTPVersion:@"1.1"
                                     headerFields:headers];
}

+ (NSData *)overrideSendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    FakeWebResponder *responder = [FakeWeb responderFor:[[request URL] absoluteString] method:[request HTTPMethod]];
    if (responder)
    {
        if (0 != response)
            *response = nil;
        *response = [self createDummyResponse:request responder:responder];
        return [[responder body] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [self overrideSendSynchronousRequest:request returningResponse:response error:error];
}

@end


@implementation NSHTTPURLResponse (FakeWeb)

+ (void)load
{
    Class c = [self class];
    SwizzleClassMethod(c, @selector(localizedStringForStatusCode:), @selector(overrideLocalizedStringForStatusCode:));
}

+ (NSString *)overrideLocalizedStringForStatusCode:(NSInteger)statusCode
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder statusMessage]
        : [self overrideLocalizedStringForStatusCode:statusCode];
}

@end
