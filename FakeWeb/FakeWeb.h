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

+(void) registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body staus:(int)status statusMessage:(NSString*)statusMessage;
+(void) registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body staus:(int)status;
+(void) registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body;

+(BOOL) registeredUri:(NSString*)uri;
+(BOOL) registeredUri:(NSString*)uri method:(NSString*)method;


+(void) registerPassthroughUri:(NSString*)uri;
+(void) registerPassthroughUri:(NSString*)uri method:(NSString*)method;

+(BOOL) registeredPassthroughUri:(NSString*)uri;
+(BOOL) registeredPassthroughUri:(NSString*)uri method:(NSString*)method;


+(void) raiseNetConnectException:(NSURL*)uri;
+(void) raiseNetConnectException:(NSURL*)uri method:(NSString*)method;

//+(FakeWebResponder*) responseFor:(NSString*)uri method:(NSString*)method;
+(FakeWebResponder*) responderFor:(NSString*)uri method:(NSString*)method;

+(BOOL) allowNetConnet;
+(BOOL) setAllowNetConnet:(BOOL)isConnect;

+(void) cleanRegistry;

@end
