//
//  AAListViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class AAListViewController;

@protocol AAListViewControllerDelegate <NSObject>

//-(void)didDismissAAListViewController:(AAListViewController *)vc;

@end

@interface AAListViewController : UIViewController <FBFriendPickerDelegate>

@property (weak, nonatomic) id <AAListViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *userList;
@property (strong, nonatomic) NSString *userFBID;



@end
