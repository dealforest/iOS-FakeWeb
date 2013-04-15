//
//  FakeWebNSURLConnectionSpec.m
//  FakeWebTests
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"
#import "FakeWeb.h"
#import "FakeWebTestNSURLConnectionViewController.h"

SPEC_BEGIN(FakeWebNSURLConnectionSpec)

describe(@"NSURLConnection+FakeWeb", ^{
    NSURL __block *url = nil;
    
    beforeEach(^{
        url = [NSURL URLWithString:@"http://exsample.com"];
        [FakeWeb cleanRegistry];
        [FakeWeb setAllowNetConnet:YES];
    });
    
    context(@"when empty registered uri", ^{
        context(@"registerUri", ^{
            it(@"synchronous request by GET", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"hoge" status:200];

                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                NSString *bodyText = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                
                [[bodyText should] equal:@"hoge"];
                [[theValue([response expectedContentLength]) should] equal:theValue([bodyText length])];
                [[theValue([response statusCode]) should] equal:theValue(200)];
                [[[NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]] should] equal:@"OK"];
                
                [[[[response allHeaderFields] objectForKey:@"Content-Type"] should] equal:@"text/plain; charset=UTF-8"];
            });
            
            it(@"synchronous request by POST", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"POST" body:@"fuga" status:200];
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                NSHTTPURLResponse *response = nil;
                NSError *error = nil;
                NSData *body = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                NSString *bodyText = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
                
                [[bodyText should] equal:@"fuga"];
                [[theValue([response expectedContentLength]) should] equal:theValue([bodyText length])];
                [[theValue([response statusCode]) should] equal:theValue(200)];
                [[[NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]] should] equal:@"OK"];
            });
        });
    });
    
    context(@"when asynchronous request", ^{
        context(@"registerUri", ^{
            it(@"request by connectionWithRequest:delegate: (GET)", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"hoge" status:200];
                
                FakeWebTestNSURLConnectionViewController *controller = [[FakeWebTestNSURLConnectionViewController alloc] init];
                NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                     timeoutInterval:10.0];
                [controller asyncRequest:request];
                [[expectFutureValue([controller getResponseString]) shouldEventuallyBeforeTimingOutAfter(1.0)] equal:@"hoge"];
            });
            
            it(@"request by sendAsynchronousRequest:queue:completionHandler: (GET)", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"hoge" status:200];
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                NSHTTPURLResponse __block *response;
                NSString __block *dataString;

                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:queue
                                       completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error) {
                                           response = (NSHTTPURLResponse *)response_;
                                           dataString = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
                                           dispatch_semaphore_signal(semaphore);
                                       }];
                
                [[expectFutureValue(dataString) shouldEventually] equal:@"hoge"];
                [[theValue([response expectedContentLength]) shouldEventually] equal:theValue(4)];
                [[theValue([response statusCode]) shouldEventually] equal:theValue(200)];
                [[expectFutureValue([NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]) shouldEventually] equal:@"OK"];
                [[expectFutureValue([[response allHeaderFields] objectForKey:@"Content-Type"]) shouldEventually] equal:@"text/plain; charset=UTF-8"];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_release(semaphore);
            });
            
            it(@"request by sendAsynchronousRequest:queue:completionHandler: (POST)", ^{
                [FakeWeb registerUri:[url absoluteString] method:@"POST" body:@"hoge" status:200];
                
                NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
                [request setHTTPMethod:@"POST"];
                
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                NSHTTPURLResponse __block *response;
                NSString __block *dataString;
                
                [NSURLConnection sendAsynchronousRequest:request
                                                   queue:queue
                                       completionHandler:^(NSURLResponse *response_, NSData *data_, NSError *error) {
                                           response = (NSHTTPURLResponse *)response_;
                                           dataString = [[NSString alloc] initWithData:data_ encoding:NSUTF8StringEncoding];
                                           dispatch_semaphore_signal(semaphore);
                                       }];
                [[expectFutureValue(dataString) shouldEventually] equal:@"hoge"];
                [[theValue([response expectedContentLength]) shouldEventually] equal:theValue(4)];
                [[theValue([response statusCode]) shouldEventually] equal:theValue(200)];
                [[expectFutureValue([NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]) shouldEventually] equal:@"OK"];
                [[expectFutureValue([[response allHeaderFields] objectForKey:@"Content-Type"]) shouldEventually] equal:@"text/plain; charset=UTF-8"];

                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_release(semaphore);
            });
        });
    });

});

SPEC_END