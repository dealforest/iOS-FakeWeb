//
//  FakeWebResponder.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 2/13/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWebResponder.h"

@implementation FakeWebResponder

@synthesize uri = uri_, method = method_, statusMessage = statusMessage_, status = status_, raiseException = raiseException_;

-(id) initWithUri:(NSString*)uri method:(NSString*)method status:(int)status statusMessage:(NSString*)statusMessage {
    self = [super init];
    if (self) {
        uri_ = uri;
        method_ = method;
        status_ = status;
        statusMessage_ = statusMessage;
        raiseException_ = FALSE;
    }
    return self;
}

-(void) setRaiseException:(BOOL)isRaiseException {
    raiseException_ = isRaiseException;
}

-(void) dealloc {
    [uri_ release], uri_ = nil;
    [method_ release], method_ = nil;
    [statusMessage_ release], statusMessage_ = nil;
}

@end
