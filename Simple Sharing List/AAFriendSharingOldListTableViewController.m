//
//  AAFriendSharingOldListTableViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 03/10/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAFriendSharingOldListTableViewController.h"


@interface AAFriendSharingOldListTableViewController ()
@property (strong, nonatomic) IBOutlet UITableView *shareButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@property (strong, nonatomic) NSMutableArray *friendArray;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *myFriends;

@property (strong, nonatomic) NSMutableArray *arrayOfId;



@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *simpleSharingListFriends;


@property (strong, nonatomic) PFUser *friendInTable;
@property (strong, nonatomic) PFUser *friendInTableId;

@end

@implementation AAFriendSharingOldListTableViewController


-(NSMutableArray *)friendList {
    if (!_friendList) {
        _friendList = [[NSMutableArray alloc] init];
    }
    
    return _friendList;
}

-(NSMutableArray *)myFriends {
    if (!_myFriends) {
        _myFriends = [[NSMutableArray alloc]init];
    }
    return _myFriends;
}

-(NSMutableArray *)selectedFriends {
    if (!_selectedFriends) {
        _selectedFriends = [[NSMutableArray alloc]init];
    }
    return _selectedFriends;
}

@synthesize  friendsAlreadyPicked = _friendsAlreadyPicked;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self updateFriendFromFB];
    [self updateFriendArray];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.friendArray count];
}

-(void)updateFriendArray {
    PFQuery *friendArray = [PFQuery queryWithClassName:AAActivityClassKey];
    [friendArray whereKey:AAActivityFromUserKey equalTo:[PFUser currentUser]];
    [friendArray includeKey:AAActivityToUserKey];
    [friendArray findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendArray removeAllObjects];
        self.friendArray = [objects mutableCopy];
        [self.tableView reloadData];
    }];
}

-(void)updateFriendFromFB {
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *queryForUser = [PFQuery queryWithClassName:AAActivityClassKey];
    [queryForUser whereKey:AAActivityFromUserKey equalTo:currentUser];
    [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendList removeAllObjects];
        [self.friendList addObjectsFromArray:objects];
        [self.friendList enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
            PFObject *friend = user;
            PFUser *friendUser = [friend objectForKey:AAActivityToUserKey];
            PFUser *userToGetId = [PFQuery getUserObjectWithId:friendUser.objectId];
            [self.myFriends addObject:userToGetId];
        }];
        
        self.arrayOfId = [[NSMutableArray alloc] initWithCapacity:[self.myFriends count]];
        for (PFUser *userForId in self.myFriends) {
            [self.arrayOfId addObject:userForId[@"facebookId"]];
        }
        
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSArray *data = [result objectForKey:@"data"];
                if (data) {
                    NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
                    for (NSDictionary *friendData in data) {
                        if (friendData[@"id"]) {
                            [facebookIds addObject:friendData[@"id"]];
                            }
                    }
                    
                    [self.arrayOfId enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx, BOOL *stop) {
                        [facebookIds enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
                            if ([obj1 isEqual:obj2]) {
                                [facebookIds removeObject:obj2];
                            }
                        }];
                    }];

                    
                    [[AACache sharedChache] setFacebookFriends:facebookIds];
                    if (currentUser){
                        if ([currentUser objectForKey:AAUserFacebookIDKey]) {
                            [currentUser removeObjectForKey:AAUserFacebookIDKey];
                        }
                        
                        
                        PFQuery *facebookFriendQuery = [PFUser query];
                        [facebookFriendQuery whereKey:AAUserFacebookIDKey containedIn:facebookIds];
                        
                        self.simpleSharingListFriends = [[NSMutableArray alloc] init];
                        
                        [facebookFriendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error) {
                                [self.simpleSharingListFriends removeAllObjects];
                                [self.simpleSharingListFriends addObjectsFromArray:objects];
                                [self.simpleSharingListFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                                    PFObject *joinActivity = [PFObject objectWithClassName:AAActivityClassKey];
                                    [joinActivity setObject:currentUser forKey:AAActivityFromUserKey];
                                    [joinActivity setObject:newFriend forKey:AAActivityToUserKey];
                                    [joinActivity setObject:AAActivityTypeJoined forKey:AAActivityTypeKey];
                                    
                                    PFACL *joinACL = [PFACL ACL];
                                    [joinACL setPublicReadAccess:YES];
                                    joinActivity.ACL = joinACL;
                                    
                                    [joinActivity save];
                                    
                                }];
                            }
                        }];
                        [currentUser saveEventually];
                    }
                }
            }
        }];

    }];
    
    [self updateFriendArray];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *Cellidentifier =  @"Cell";
    //NSString *currentUserId = currentUser.objectId;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier forIndexPath:indexPath];
    
    PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
    self.friendInTable = [friend objectForKey:@"toUser"];
    [self.selectedFriends addObject:self.friendInTable];
    cell.textLabel.text = self.friendInTable[@"name"];
    
    [self.friendsAlreadyPicked enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
        if ([user.objectId isEqual:self.friendInTable.objectId]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            *stop = YES;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    }];
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
        self.friendInTable = [friend objectForKey:@"toUser"];
        [self.selectedFriends addObject:self.friendInTable];
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.selectedFriends objectAtIndex:indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareBarButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate didPickFriendForOldList:self.selectedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
