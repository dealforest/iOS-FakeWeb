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
#import "NSURLConnection+FakeWeb.h"

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
                [FakeWeb registerUri:[url absoluteString] method:@"GET" body:@"hoge" staus:200];

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
                [FakeWeb registerUri:[url absoluteString] method:@"POST" body:@"fuga" staus:200];
                
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

});

SPEC_END