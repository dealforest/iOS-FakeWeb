//
//  FakeWebAHIHTTPRequestTests.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 5/15/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"
#import "ASIHTTPRequest+FakeWeb.h"

SPEC_BEGIN(FakeWebAHIHTTPRequestSpec)

describe(@"テスト対象", ^{
    context(@"状態", ^{
        context(@"テスト対象メソッド", ^{
            it(@"与える入力", ^{
                @"期待する出力";
                
                
                NSURL *url = [NSURL URLWithString:@"http://exsample.com"];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                [request setDelegate:self];
                [request startAsynchronous];
                NSLog(@"====> %d", [request responseStatusCode]);
                NSLog(@"====> %@", [request responseString]);
            });
        });
    });
});

SPEC_END
