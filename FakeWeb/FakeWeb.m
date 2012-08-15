//
//  FakeWeb.m
//  FakeWeb
//
//  Created by Toshihiro Morimoto on 2/8/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWeb.h"
#import "FakeWeb+Private.h"

#define ALL_HTTP_METHOD [NSArray arrayWithObjects:@"GET", @"POST", @"PUT", @"DELETE", nil]

NSString * const FakeWebRequestKey = @"FakeWebRequestKey";
NSString * const FakeWebNotAllowedNetConnetException = @"FakeWebNotAllowedNetConnetException";

static NSMutableDictionary *uriMap;
static NSMutableDictionary *passthroughUriMap;
static BOOL allowNetConnect;
static BOOL autoCleanup;
static FakeWebResponder *matchingResponder;

@implementation FakeWeb

+ (void)initialize
{
    uriMap = [NSMutableDictionary new];
    passthroughUriMap = [NSMutableDictionary new];
    allowNetConnect = autoCleanup = TRUE;
    matchingResponder = nil;
}

#pragma mark -
#pragma mark register method

+(void) registerUri:(NSString *)uri method:(NSString *)method rotatingResponse:(NSArray *)rotatingResponses
{
    if (!method) return;
    
    NSMutableArray *responders = [NSMutableArray array];
    for (NSDictionary *response in rotatingResponses) {
        NSString *body = [response objectForKey:@"body"];
        if ([body length] == 0) continue;
        
        NSInteger statusCode = 200;
        id status = [response objectForKey:@"status"];
        if ([status isKindOfClass:[NSString class]] || [status isKindOfClass:[NSNumber class]])
            statusCode = [(NSString *)status integerValue];
    
        FakeWebResponder *responder = [[FakeWebResponder alloc] initWithUri:uri 
                                                                     method:method 
                                                                       body:body
                                                                     status:statusCode
                                                              statusMessage:[response objectForKey:@"statusMessage"]];
        [responders addObject:responder];
    }
    if ([responders count] == 0) return;
    
    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        [uriMap setObject:responders forKey:[self keyForUri:uri method:method_]];
    }
}

+ (void)registerUri:(NSString *)uri method:(NSString *)method body:(NSString *)body staus:(NSInteger)status
{
    [self registerUri:uri method:method body:body staus:status statusMessage:nil];
}

+ (void)registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body 
{
    [self registerUri:uri method:method body:body staus:200 statusMessage:nil];
}

+ (void)registerUri:(NSString*)uri method:(NSString*)method body:(NSString*)body staus:(NSInteger)status statusMessage:(NSString*)statusMessage 
{
    if (!method) return;
    
    FakeWebResponder *responder = [[FakeWebResponder alloc] initWithUri:uri method:method body:body status:status statusMessage:statusMessage];

    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        NSString *key = [self keyForUri:uri method:method_];
        NSMutableArray *responders = (NSMutableArray *)[uriMap objectForKey:key];
        if (responders)
        {
            [responders removeAllObjects];
            [responders addObject:responder];
        }
        else 
            responders = [NSMutableArray arrayWithObjects:responder, nil];
        [uriMap setObject:responders forKey:key];
    }
}

+(void) registerPassthroughUri:(NSString *)uri
{
    [self registerPassthroughUri:uri method:@"ANY"];
}

+ (void)registerPassthroughUri:(NSString*)uri method:(NSString*)method 
{
    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        NSString *key = [self keyForUri:uri method:method_];
        [passthroughUriMap setValue:[NSString stringWithFormat:@"%d", YES] forKey:key];
    }
}

#pragma mark -
#pragma mark check method

+ (BOOL)registeredUri:(NSString*)uri 
{
    return [self registeredUri:uri method:@"ANY"];
}

+ (BOOL)registeredUri:(NSString*)uri method:(NSString*)method 
{
    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        NSString *key = [self keyForUri:uri method:method_];
        NSMutableArray *responders = (NSMutableArray *)[uriMap objectForKey:key];
        return [responders count] > 0 ? YES : NO;
    }
    return NO;
}

+ (BOOL)registeredPassthroughUri:(NSString*)uri 
{
    return [self registeredPassthroughUri:uri method:@"ANY"];
}

+ (BOOL)registeredPassthroughUri:(NSString*)uri method:(NSString*)method
{
    NSArray *methods = [self convertToMethodList:method];
    for (NSString *method_ in methods)
    {
        NSString *key = [self keyForUri:uri method:method_];
        if ([passthroughUriMap objectForKey:key])
            return TRUE;
    }
    return FALSE;
}

#pragma mark -
#pragma mark throw exception method

+ (void)raiseNetConnectException:(NSString *)uri method:(NSString*)method
{
	@throw [NSException exceptionWithName:FakeWebNotAllowedNetConnetException
                                   reason:[self keyForUri:uri method:method]
                                 userInfo:nil];
}

#pragma mark -
#pragma mark option method

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
}

+ (FakeWebResponder *)responderFor:(NSString *)uri method:(NSString *)method
{
    matchingResponder = nil;
    if (allowNetConnect == NO && [self registeredPassthroughUri:uri method:method] == NO) {
        [self raiseNetConnectException:uri method:method];
        return nil;
    }

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

#pragma mark -
#pragma mark private method

+(FakeWebResponder *) matchingResponder {
    return matchingResponder;
}

+(void) setMatchingResponder:(FakeWebResponder *)responder {
    matchingResponder = responder;
}

+(FakeWebResponder *) uriMapMatches:(NSMutableDictionary *)map uri:(NSString *)uri method:(NSString *)method type:(NSString *)type
{
    NSString *key = [self keyForUri:uri method:method];
    
    if ([type isEqualToString:@"URI"]) 
    {
        matchingResponder = [self matchingFirstResponser:map key:key];
        return matchingResponder;
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
                    matchingResponder = [self matchingFirstResponser:map key:key_];
                    return matchingResponder;
                }
            }
        }
    }
    return nil;
}

+(FakeWebResponder *) matchingFirstResponser:(NSDictionary *)map key:(NSString *)key
{
    NSMutableArray *responders = [map objectForKey:key];
    if ([responders count] == 1)
    {
        return [responders objectAtIndex:0];
    }
    else
    {
        FakeWebResponder *responder = [responders objectAtIndex:0];
        [responders removeObjectAtIndex:0];
        [responders addObject:responder];
        return responder;
    }
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
    if ([url count] > 1)
    {
        NSArray *params = [[url objectAtIndex:1] componentsSeparatedByString:@"&"];
        NSArray *sortParams = [params sortedArrayUsingSelector:@selector(compare:)];
        return [NSString stringWithFormat:@"%@?%@", [url objectAtIndex:0], [sortParams componentsJoinedByString:@"&"]];
    }
    return uri;
}

/*
 * see http://stackoverflow.com/questions/1637604/method-swizzle-on-iphone-device
 */

void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) 
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

void SwizzleClassMethod(Class c, SEL orig, SEL new)
{
    Swizzle(object_getClass((id)c), orig, new);
}


@end
