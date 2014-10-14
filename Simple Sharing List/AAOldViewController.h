//
//  AAOldViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AAFriendSharingOldListTableViewController.h"

@class AAOldViewController;

@protocol  AAOldViewControllerDelegate <NSObject>


@end



@interface AAOldViewController : UIViewController <AAFriendSharingOldListTableViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) id <AAOldViewControllerDelegate> delegate;

@property (strong, nonatomic) PFObject *oldList;

@end
