//
//  FakeWeb+Private.h
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 5/6/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWeb.h"

@interface FakeWeb (private)

+(FakeWebResponder *) matchingResponder;

+(void) setMatchingResponder:(FakeWebResponder *)responder;

+(FakeWebResponder *) responderFor:(NSString *)uri method:(NSString *)method;

+(FakeWebResponder *) uriMapMatches:(NSMutableDictionary *)map uri:(NSString *)uri method:(NSString *)method type:(NSString *)type;

+(FakeWebResponder *) matchingFirstResponser:(NSDictionary *)map key:(NSString *)key;

+(NSArray *) convertToMethodList:(NSString *)method;

+(NSString *) keyForUri:(NSString *)uri method:(NSString *)method;

+(NSString *) normalizeUri:(NSString *)uri;

+(NSString *) sortQuery:(NSString *)uri;

@end
