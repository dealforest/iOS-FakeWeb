//
//  FakeWebResponder.h
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 2/13/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeWebResponder : NSObject {
    NSString    *_uri;
    NSString    *_method;
    NSString    *_body;
    NSString    *_statusMessage;
    int         _status;
}

@property (nonatomic, strong) NSString *uri;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSString *statusMessage;
@property (nonatomic) int status;

-(id) initWithUri:(NSString *)uri method:(NSString *)method body:(NSString *)body status:(NSInteger)status statusMessage:(NSString *)statusMessage;

@end
