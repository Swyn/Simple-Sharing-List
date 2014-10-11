//
//  AAFriendSharingOldListTableViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 03/10/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAFriendSharingOldListTableViewControllerDelegate <NSObject>

-(void)didPickFriend:(NSMutableArray *)friendsPicked;

@end

@interface AAFriendSharingOldListTableViewController : UITableViewController

@property (weak) id<AAFriendSharingOldListTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSArray *friendsAlreadyPicked;

@end
