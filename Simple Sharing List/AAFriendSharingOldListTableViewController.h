//
//  AAFriendSharingOldListTableViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 03/10/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAFriendSharingOldListTableViewControllerDelegate <NSObject>

-(void)didPickFriendForOldList:(NSMutableArray *)friendsPickedForOldList;

@end

@interface AAFriendSharingOldListTableViewController : UITableViewController

@property (weak) id <AAFriendSharingOldListTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *friendsAlreadyPicked;

@end
