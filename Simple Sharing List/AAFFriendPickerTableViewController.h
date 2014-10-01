//
//  AAFBFriendPickerTableViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 29/09/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AAFFriendPickerTableViewControllerDelegate <NSObject>

-(void)didPickFriends:(NSMutableArray*)friendsPicked;

@end

@interface AAFFriendPickerTableViewController : UITableViewController

@property (weak) id <AAFFriendPickerTableViewControllerDelegate> delegate;


@end
