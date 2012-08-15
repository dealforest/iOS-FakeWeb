//
//  FakeWebTestNSURLConnectionViewController.h
//  FakeWeb
//
//  Created by Toshirhio Morimoto on 6/27/12.
//  Copyright (c) 2012 Toshihiro Morimoto (id:dealforest). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FakeWebTestNSURLConnectionViewController : UIViewController <NSURLConnectionDelegate>
{
    NSURLConnection *_connection;
    NSMutableData   *_data;
    NSError         *_error;
    NSURLResponse   *_response;
    BOOL            _isSuccess;
}

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, assign) BOOL isSuccess;

-(NSString *) getResponseString;

-(void) asyncRequest:(NSURLRequest *)request;

@end