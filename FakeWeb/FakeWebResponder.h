//
//  FakeWebResponder.h
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 2/13/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeWebResponder : NSObject {
    NSString    *uri_;
    NSString    *method_;
    NSString    *statusMessage_;
    int         status_;
    BOOL        raiseException_;
}

@property (nonatomic, retain) NSString *uri;
@property (nonatomic, retain) NSString *method;
@property (nonatomic, retain) NSString *statusMessage;
@property (nonatomic) int status;
@property (nonatomic) BOOL raiseException;

-(id) initWithUri:(NSString*)uri method:(NSString*)method status:(int)status statusMessage:(NSString*)statusMessage;

-(void) setRaiseException:(BOOL)isRaiseException;

@end
