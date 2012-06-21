//
//  FakeWebAHIHTTPRequestTests.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 5/15/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"
#import "FakeWeb.h"
#import "ASIHTTPRequest+FakeWeb.h"
#import "ASIFormDataRequest.h"

SPEC_BEGIN(FakeWebAHIHTTPRequestSpec)

describe(@"ASIHTTPRequest+FakeWeb", ^{
    NSURL __block *url;
    
    beforeEach(^{
        url = [NSURL URLWithString:@"http://exsample.com"];
        [FakeWeb cleanRegistry];
        [FakeWeb setAllowNetConnet:YES];
    });
    
    context(@"when empty registered uri", ^{
        context(@"registerUri", ^{
            it(@"normal process", ^{
                [FakeWeb registerUri:@"http://exsample.com" method:@"GET" body:@"hoge" staus:200];
                
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
                [[theValue([request responseStatusCode]) should] equal:theValue(200)];
                [[[request responseString] should] equal:@"hoge"];
            });
        });
    });
    
    context(@"when don't allowd netconncect", ^{
        context(@"setAllowNetConnet", ^{
            afterEach(^{
                [FakeWeb setAllowNetConnet:YES]; 
            });
            
            it(@"process is allowed net connect", ^{
                [FakeWeb setAllowNetConnet:YES];
                
                [FakeWeb registerUri:@"http://exsample.com" method:@"GET" body:@"hoge" staus:200];
                
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
                [[theValue([request responseStatusCode]) should] equal:theValue(200)];
                [[[request responseString] should] equal:@"hoge"];
            });

            it(@"process is not allowed net connect on non-regsiter", ^{
                [FakeWeb setAllowNetConnet:NO];
                
                @try {
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    [request startSynchronous];
                }
                @catch (NSException *exception) {
                    [[[exception name] should] equal:@"FakeWebNotAllowedNetConnetException"];
                }
            });
            
            it(@"process is not allowed net connect already regsiter", ^{
                [FakeWeb setAllowNetConnet:NO];
                
                [FakeWeb registerUri:@"http://exsample.com" method:@"GET" body:@"hoge" staus:200];
                
                @try {
                    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                    [request startSynchronous];
                }
                @catch (NSException *exception) {
                    [[[exception name] should] equal:@"FakeWebNotAllowedNetConnetException"];
                }
            });
        });
    });
    
    context(@"when adding a custom status to the response", ^{
        context(@"registerUri", ^{
            it(@"regsitetr 404 response", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"Nothing to be found 'round here" staus:404 statusMessage:@"Not Found"];
                
                ASIHTTPRequest *request;
                request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
                [[theValue([request responseStatusCode]) should] equal:theValue(404)];
                [[[request responseString] should] equal:@"Nothing to be found 'round here"];
            });
        });
    });
    
    context(@"when responding to any HTTP method", ^{
        context(@"registerUri", ^{
            it(@"request method is GET and POST", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"ANY" body:@"Nothing to be found 'round here" staus:404 statusMessage:@"Not Found"];
                
                ASIHTTPRequest *request;
                request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
                [[theValue([request responseStatusCode]) should] equal:theValue(404)];
                [[[request responseString] should] equal:@"Nothing to be found 'round here"];
                
                ASIFormDataRequest *formRequest;
                formRequest = [ASIFormDataRequest requestWithURL:url];
                [formRequest setRequestMethod:@"POST"];
                [formRequest startSynchronous];
                [[theValue([request responseStatusCode]) should] equal:theValue(404)];
                [[[request responseString] should] equal:@"Nothing to be found 'round here"];
            });
        });
    });
    
    context(@"when rotating responses", ^{
        context(@"registerUri", ^{
            it(@"regsitetr 2 response", ^{
                
                ASIHTTPRequest *request;
                request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
            });
        });
    });
    
    context(@"when need authorization request", ^{
        context(@"registerUri", ^{
            it(@"input valid parameter", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"Unauthorized" staus:401 statusMessage:@"Unauthorized"];
                
                ASIHTTPRequest *request;
                request = [ASIHTTPRequest requestWithURL:url];
                [request startSynchronous];
                [[[request responseString] should] equal:@"Unauthorized"];

                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"Authorized"];
                
                request = [ASIHTTPRequest requestWithURL:url];
                [request setUsername:@"user"];
                [request setPassword:@"pass"];
                [request startSynchronous];
                [[[request responseString] should] equal:@"Authorized"];
            });
        });
    });
});

SPEC_END
