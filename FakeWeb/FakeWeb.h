//
//  FakeWeb.h
//  FakeWeb
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FakeWebResponder.h"

@interface FakeWeb : NSObject

#pragma mark -
#pragma mark register method

+(void) registerUri:(NSString *)uri method:(NSString *)method rotatingResponse:(NSArray *)rotatingResponses;

+(void) registerUri:(NSString *)uri method:(NSString *)method body:(NSString *)body status:(NSInteger)status statusMessage:(NSString *)statusMessage;
+(void) registerUri:(NSString *)uri method:(NSString *)method body:(NSString *)body status:(NSInteger)status;
+(void) registerUri:(NSString *)uri method:(NSString *)method body:(NSString *)body;

+(void) registerPassthroughUri:(NSString *)uri;
+(void) registerPassthroughUri:(NSString *)uri method:(NSString *)method;

#pragma mark -
#pragma mark check method

+(BOOL) registeredPassthroughUri:(NSString *)uri;
+(BOOL) registeredPassthroughUri:(NSString *)uri method:(NSString *)method;

+(BOOL) registeredUri:(NSString *)uri;
+(BOOL) registeredUri:(NSString *)uri method:(NSString *)method;

#pragma mark -
#pragma mark throw exception method

+(void) raiseNetConnectException:(NSString *)uri method:(NSString *)method;

#pragma mark -
#pragma mark option method

+(BOOL) allowNetConnet;
+(BOOL) setAllowNetConnet:(BOOL)isConnect;
+(void) cleanRegistry;

@end
