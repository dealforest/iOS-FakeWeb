//
//  FakeWebTests.m
//  FakeWebTests
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"
#import "FakeWeb.h"
#import "FakeWeb+Private.h"

SPEC_BEGIN(FakeWebSpec)

describe(@"FakeWeb", ^{
    context(@"When non-dependence", ^{
        beforeAll(^{
            [FakeWeb setAllowNetConnet:YES];
        });
        
        context(@"'allowNetConnet'", ^{
            it(@"setter and getter", ^{
                [[theValue([FakeWeb allowNetConnet]) should] beYes];
                [[theValue([FakeWeb setAllowNetConnet:NO]) should] beFalse];
                [[theValue([FakeWeb allowNetConnet]) should] beFalse];
                [[theValue([FakeWeb setAllowNetConnet:YES]) should] beTrue];
            });
        });
    });
    
    context(@"When non-regsiter", ^{
        
        afterEach(^{
            [FakeWeb cleanRegistry];
        });
        
        NSString __block *url1= @"http://exsample.com/";
        NSString __block *url2 = @"http://exsample.com/hoge/fuga?test=1";
        NSString __block *url3 = @"http://exsample.com/hoge";
        
        context(@"'registerUri'", ^{
            it(@"regsiter", ^{
                [FakeWeb registerUri:url1 method:@"GET" body:@"hoge"];
                [[theValue([FakeWeb registeredUri:url1]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url1 method:@"GET"]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url1 method:@"POST"]) should] beFalse];
                [[theValue([FakeWeb registeredUri:url1 method:@"PUT"]) should] beFalse];
                [[theValue([FakeWeb registeredUri:url1 method:@"DELETE"]) should] beFalse];
                
                [FakeWeb registerUri:url2 method:@"ANY" body:@"fuga"];
                [[theValue([FakeWeb registeredUri:url2]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url2 method:@"GET"]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url2 method:@"POST"]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url2 method:@"PUT"]) should] beTrue];
                [[theValue([FakeWeb registeredUri:url2 method:@"DELETE"]) should] beTrue];
            });
        });
        
        context(@"'registeredPassthroughUri'", ^{
            it(@"regsiter", ^{
                [FakeWeb registerPassthroughUri:url1];
                [[theValue([FakeWeb registeredPassthroughUri:url1]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url1 method:@"GET"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url1 method:@"POST"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url1 method:@"PUT"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url1 method:@"DELETE"]) should] beTrue];
                
                [FakeWeb registerPassthroughUri:url2 method:@"GET"];
                [[theValue([FakeWeb registeredPassthroughUri:url2]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url2 method:@"GET"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url2 method:@"POST"]) should] beFalse];
                [[theValue([FakeWeb registeredPassthroughUri:url2 method:@"PUT"]) should] beFalse];
                [[theValue([FakeWeb registeredPassthroughUri:url2 method:@"DELETE"]) should] beFalse];
                
                [FakeWeb registerPassthroughUri:url3 method:@"ANY"];
                [[theValue([FakeWeb registeredPassthroughUri:url3]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url3 method:@"GET"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url3 method:@"POST"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url3 method:@"PUT"]) should] beTrue];
                [[theValue([FakeWeb registeredPassthroughUri:url3 method:@"DELETE"]) should] beTrue];
            });
        });
        
        context(@"'cleanRegistry'", ^{
            it(@"cleanup", ^{
                [FakeWeb registerUri:url1 method:@"GET" body:@"hoge"];
                [FakeWeb cleanRegistry];
                [[theValue([FakeWeb registeredUri:url1]) should] beFalse];
            });
        });
    });
        

    context(@"test private API", ^{
        context(@"'convertToMethodList'", ^{
            it(@"http method is post", ^{
                [[theValue([[FakeWeb convertToMethodList:@"POST"] count]) should] equal:theValue(1)];
            });
            it(@"http method is any", ^{
                [[theValue([[FakeWeb convertToMethodList:@"ANY"] count]) should] equal:theValue(4)];
            });
        });
        context(@"'normalizeUri'", ^{
            it(@"lower url string", ^{
                [[[FakeWeb normalizeUri:@"http://EXSAMPLE.COM"] should] equal:@"http://exsample.com"];
                [[[FakeWeb normalizeUri:@"http://ExsampLe.coM/Hoge/Fuga/FOO"] should] equal:@"http://exsample.com/hoge/fuga/foo"];
            });
            it(@"lower url and query parameter string", ^{
                [[[FakeWeb normalizeUri:@"http://EXSAMPLE.COM?HOGE=fuga"] should] equal:@"http://exsample.com?hoge=fuga"];
                [[[FakeWeb normalizeUri:@"http://ExsampLe.coM/Hoge/Fuga/FOO?HOOO=OOO&a=B"] should] equal:@"http://exsample.com/hoge/fuga/foo?hooo=ooo&a=b"];
            });
        });
        context(@"'sortQuery'", ^{
            it(@"sort query paramter", ^{
                [[[FakeWeb sortQuery:@"http://exsample.com/?a=b"] should] equal:@"http://exsample.com/?a=b"];
                [[[FakeWeb sortQuery:@"http://exsample.com/?b=a&a=b"] should] equal:@"http://exsample.com/?a=b&b=a"];
                [[[FakeWeb sortQuery:@"http://exsample.com/?hoge=fuga&b=a&a=b"] should] equal:@"http://exsample.com/?a=b&b=a&hoge=fuga"];
            });
        });
    });
});

SPEC_END