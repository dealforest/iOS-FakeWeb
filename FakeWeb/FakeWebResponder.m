//
//  FakeWebResponder.m
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 2/13/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import "FakeWebResponder.h"

@implementation FakeWebResponder

@synthesize uri = _uri, method = _method, statusMessage = _statusMessage, status = _status, raiseException = _raiseException;

-(id) initWithUri:(NSString*)uri method:(NSString*)method status:(int)status statusMessage:(NSString*)statusMessage {
    self = [super init];
    if (self) {
        _uri = uri;
        _method = method;
        _status = status;
        _statusMessage = statusMessage;
        _raiseException = FALSE;
    }
    return self;
}

@end
