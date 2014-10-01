//
//  AALoginViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AALoginViewController : UIViewController<NSURLConnectionDataDelegate>

@property (nonatomic, readonly) int networkStatus;

-(BOOL)isParseReachable;

-(void)facebookRequestDidLoad:(id)result;
-(void)facebookRequestDidFailWithError:(NSError *)error;

@property (nonatomic, strong) NSMutableArray *simpleSharingListFriends;


@end
