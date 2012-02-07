//
//  FakeWebTests.m
//  FakeWebTests
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#define KIWI_DISABLE_MACRO_API

#import "Kiwi.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 21;
        NSUInteger b = 21;
        [[theValue(a + b) should] equal:theValue(42)];
    });
});

SPEC_END