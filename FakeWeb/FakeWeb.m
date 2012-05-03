//
//  FakeWeb.m
//  FakeWeb
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWeb.h"

#define ALL_HTTP_METHOD [NSArray arrayWithObjects: @"GET", @"POST", @"PUT", @"DELETE", nil]

static NSMutableDictionary *uriMap;
static NSMutableDictionary *passthroughUriMap;
static NSMutableDictionary *raiseExceptionUriMap;
static BOOL allowNetConnect;
static BOOL autoCleanup;

@interface FakeWeb(Private)
+(FakeWebResponder*) uriMapMatches:(NSMutableDictionary*)map uri:(NSString*)uri method:(NSString*)method type:(NSString*)type;
+(NSArray *) convertToMethodList:(NSString *)method;
+(NSString*) normalizeUri:(NSString*)uri;
+(NSString*) sortQuery:(NSString*)uri;
@end

@implementation FakeWeb

+ (void)initialize 
{
    uriMap = [NSMutableDictionary dictionary];
    passthroughUriMap = [NSMutableDictionary dictionary];
    raiseExceptionUriMap = [NSMutableDictionary dictionary];
    allowNetConnect = autoCleanup = TRUE;
}

//--------------------------------------------------------------//
#pragma mark -- register --
//--------------------------------------------------------------//

+(void) registerUri:(NSString*)uri method:(NSString*)method rotatingBody:(NSArray *)bodies
{
}

+ (void)registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body staus:(int)status
{
    [self registerUri:uri method:method body:body staus:status statusMessage:nil];
}

+ (void)registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body 
{
    [self registerUri:uri method:method body:body staus:200 statusMessage:nil];
}

+ (void)registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body staus:(int)status statusMessage:(NSString*)statusMessage 
{
    if (!method) return;
    
    NSString *key = [self keyForUri:uri method:method];
    FakeWebResponder *responder = [[FakeWebResponder alloc] initWithUri:uri method:method status:status statusMessage:statusMessage];

    NSMutableArray *responders = (NSMutableArray *)[uriMap objectForKey:key];
    if (responders)
    {
        [responders addObject:responder];
    }
    else 
    {
        responders = [NSMutableArray arrayWithObjects:responder, nil];
    }

    [uriMap setObject:responders forKey:key];
}

+ (void)registerPassthroughUri:(NSString*)uri 
{
    [self registerPassthroughUri:uri method:@"ANY"];
}

+ (void)registerPassthroughUri:(NSString*)uri method:(NSString*)method 
{
    NSString *key = [self keyForUri:uri method:method];
    [passthroughUriMap setValue:[NSString stringWithFormat:@"%d", YES] forKey:key];
}

//--------------------------------------------------------------//
#pragma mark -- confirm --
//--------------------------------------------------------------//

+ (BOOL)registeredUri:(NSString*)uri 
{
    return [self registeredUri:uri method:@"ANY"];
}

+ (BOOL)registeredUri:(NSString*)uri method:(NSString*)method 
{
    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        NSString *key = [self keyForUri:uri method:method];
        return [uriMap objectForKey:key] ? YES : NO;
    }
    return NO;
}

+ (BOOL)registeredPassthroughUri:(NSString*)uri 
{
    return [self registeredPassthroughUri:uri method:@"ANY"];
}

+ (BOOL)registeredPassthroughUri:(NSString*)uri method:(NSString*)method
{
    NSString *key = [self keyForUri:uri method:method];
    return [passthroughUriMap objectForKey:key] ? TRUE : FALSE;
}

//--------------------------------------------------------------//
#pragma mark -- thorow exception --
//--------------------------------------------------------------//

+ (void)raiseNetConnectException:(NSString *)uri
{
    [self raiseNetConnectException:uri method:@"ANY"];
}

+ (void)raiseNetConnectException:(NSString *)uri method:(NSString*)method
{
    NSString *key = [self keyForUri:uri method:method];
    [raiseExceptionUriMap setValue:[NSString stringWithFormat:@"%d", TRUE] forKey:key];
}

//--------------------------------------------------------------//
#pragma mark -- settings --
//--------------------------------------------------------------//

+ (BOOL)allowNetConnet
{
    return allowNetConnect;
}

+ (BOOL)setAllowNetConnet:(BOOL)isConnect
{
    allowNetConnect = isConnect;
    return [self allowNetConnet];
}

+ (void)cleanRegistry
{
    [uriMap removeAllObjects];
    [passthroughUriMap removeAllObjects];
    [raiseExceptionUriMap removeAllObjects];
}

+ (FakeWebResponder*)responderFor:(NSString*)uri method:(NSString*)method
{
    FakeWebResponder *responder;
    responder = [self uriMapMatches:uriMap uri:uri method:method type:@"URI"];
    if (responder) return responder;
    
    responder = [self uriMapMatches:uriMap uri:uri method:@"ANY" type:@"URI"];
    if (responder) return  responder;
    
    responder = [self uriMapMatches:uriMap uri:uri method:method type:@"REGEX"];
    if (responder) return responder;
    
    responder = [self uriMapMatches:uriMap uri:uri method:@"ANY" type:@"REGEX"];
    return responder;
}

//--------------------------------------------------------------//
#pragma mark -- private --
//--------------------------------------------------------------//

+(FakeWebResponder *) uriMapMatches:(NSMutableDictionary *)map uri:(NSString *)uri method:(NSString *)method type:(NSString *)type
{
    NSString *key = [self keyForUri:uri method:method];
    if ([type isEqualToString:@"URI"]) 
    {
        return [map objectForKey:key];
    }
    else {
        NSArray *methods = [self convertToMethodList:method];
        for (NSString *mapKey in [map allKeys]) 
        {
            NSString *uri_ = [[mapKey componentsSeparatedByString:@" "] objectAtIndex:1];
            for (NSString *method_ in methods)
            {
                NSString *key_ = [self keyForUri:uri_ method:method];
                NSError *error;
                NSRegularExpression *regex = [NSRegularExpression 
                                              regularExpressionWithPattern:key_
                                              options:NSRegularExpressionCaseInsensitive 
                                              error:&error];
                if (error) return nil;
                
                if ([regex numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0) 
                {
                    return [uriMap objectForKey:key_];
                }
            }
        }
    }
    return nil;
}

+(NSArray *) convertToMethodList:(NSString *)method 
{
    if (!method || [method isKindOfClass:[NSNull class]])
        return nil;
    
    return [method isEqualToString:@"ANY"] ? ALL_HTTP_METHOD : [NSArray arrayWithObjects:method, nil];
}

+(NSString *) keyForUri:(NSString *)uri method:(NSString *)method
{
    return [NSString stringWithFormat:@"%@ %@", method, [self sortQuery:[self normalizeUri:uri]]];
}

+(NSString*) normalizeUri:(NSString*)uri
{
    return [uri lowercaseString];
}

+(NSString*) sortQuery:(NSString *)uri
{
    NSArray *url = [uri componentsSeparatedByString:@"?"];
    if ([url objectAtIndex:1]) 
    {
        NSArray *params = [[url objectAtIndex:1] componentsSeparatedByString:@"&"];
        NSArray *sortParams = [params sortedArrayUsingSelector:@selector(compare:)];
        return [NSString stringWithFormat:@"%@?%@", [url objectAtIndex:0], [sortParams componentsJoinedByString:@"&"]];
    }
    return uri;
}

@end
