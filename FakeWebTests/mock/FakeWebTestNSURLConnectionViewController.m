//
//  FakeWebTestNSURLConnectionViewController.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 6/27/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWebTestNSURLConnectionViewController.h"

@implementation FakeWebTestNSURLConnectionViewController

@synthesize connection = _connection, data = _data, error = _error, response = _response, isSuccess = _isSuccess;

- (id)init
{
    self = [super init];
    if (self)
    {
        _connection = nil, _error = nil, _response = nil;
        _data = [NSMutableData data];
        _isSuccess = NO;
    }
    return self;
}

-(NSString *) getResponseString
{
    return [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding];
}

- (void) asyncRequest:(NSURLRequest *)request
{
    _connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [_data setLength:0];
    _response = response;
    _isSuccess = FALSE;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _error = error;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _isSuccess = YES;
}

@end
