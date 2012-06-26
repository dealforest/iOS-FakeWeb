//
//  NSURLConnection+FakeWeb.h
//  FakeWeb
//
//  Created by dealforest on 12/06/25.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (FakeWeb)

+ (NSData *)overrideSendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;

@end
