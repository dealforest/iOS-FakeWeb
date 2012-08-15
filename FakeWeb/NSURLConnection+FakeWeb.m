//
//  NSURLConnection+FakeWeb.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 12/06/25.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "NSURLConnection+FakeWeb.h"
#import "FakeWeb+Private.h"

@implementation NSURLConnection (FakeWeb)

+ (void)load
{
    Class c = [self class];
    SwizzleClassMethod(c, @selector(sendSynchronousRequest:returningResponse:error:), @selector(override_sendSynchronousRequest:returningResponse:error:));
    SwizzleClassMethod(c, @selector(sendAsynchronousRequest:queue:completionHandler:), @selector(override_sendAsynchronousRequest:queue:completionHandler:));
    SwizzleClassMethod(c, @selector(connectionWithRequest:delegate:), @selector(override_connectionWithRequest:delegate:));
}

+ (NSData *)override_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error
{
    FakeWebResponder *responder = [FakeWeb responderFor:[[request URL] absoluteString] method:[request HTTPMethod]];
    if (responder)
    {
        if (response != 0)
            *response = nil;
        *response = [self createDummyResponse:request responder:responder];
        return [[responder body] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return [self override_sendSynchronousRequest:request returningResponse:response error:error];
}

+ (NSURLConnection *)override_connectionWithRequest:(NSURLRequest *)request delegate:(id)delegate;
{
    FakeWebResponder *responder = [FakeWeb responderFor:[[request URL] absoluteString] method:[request HTTPMethod]];
    if (responder)
    {
        //TODO: implemantation is subtlety.
        NSHTTPURLResponse *response = [self createDummyResponse:request responder:responder];
        [delegate connection:nil didReceiveResponse:response];
        [delegate connection:nil didReceiveData:[[responder body] dataUsingEncoding:NSUTF8StringEncoding]];
        [delegate connectionDidFinishLoading:nil];
        return nil;
    }
    
    return [self override_connectionWithRequest:request delegate:delegate];
}

#pragma mark -
#pragma mark private category method

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

@end

#pragma mark -

@implementation NSHTTPURLResponse (FakeWeb)

+ (void)load
{
    Class c = [self class];
    SwizzleClassMethod(c, @selector(localizedStringForStatusCode:), @selector(override_localizedStringForStatusCode:));
}

+ (NSString *)override_localizedStringForStatusCode:(NSInteger)statusCode
{
    FakeWebResponder *responder = [FakeWeb matchingResponder];
    return responder
        ? [responder statusMessage]
        : [self override_localizedStringForStatusCode:statusCode];
}

@end
