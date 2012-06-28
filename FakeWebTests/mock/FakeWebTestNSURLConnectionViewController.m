//
//  FakeWebTestNSURLConnectionViewController.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 6/27/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWebTestNSURLConnectionViewController.h"

@implementation FakeWebTestNSURLConnectionViewController

@synthesize connection = connection_, data = data_, error = error_, response = response_, isSuccess = isSuccess_;

- (id)init
{
    self = [super init];
    if (self)
    {
        connection_ = nil, error_ = nil, response_ = nil;
        data_ = [NSMutableData data];
        isSuccess_ = NO;
    }
    return self;
}

-(NSString *) getResponseString
{
    return [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
}

- (void) asyncRequest:(NSURLRequest *)request
{
    connection_ = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data_ setLength:0];
    response_ = response;
    isSuccess_ = FALSE;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [data_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    error_ = error;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isSuccess_ = YES;
}

@end
