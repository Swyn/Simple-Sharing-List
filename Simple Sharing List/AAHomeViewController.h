//
//  AAHomeViewController.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AAHomeViewController : PFQueryTableViewController

@property (strong, nonatomic) PFObject *createList;

@end
