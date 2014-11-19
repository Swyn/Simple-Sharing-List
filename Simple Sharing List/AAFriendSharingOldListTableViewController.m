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

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.parseClassName = AAActivityClassKey;
        self.pullToRefreshEnabled = YES;
    }
    
    return self;
}


@synthesize  friendsAlreadyPicked = _friendsAlreadyPicked;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //Check from the segue if the user is selected or Not
    [self.friendsAlreadyPicked enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
            [self.selectedFriends addObject:user];
        NSLog(@"selected friends : %@", self.selectedFriends);
    }];
    
    [self updateFriendFromFB];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    if (!error) {
        [self updateFriendArray];
    }
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *obj = nil;
    if (indexPath.row < self.objects.count)
    {
        obj = [self.objects objectAtIndex:indexPath.row];
    }
    
    return obj;
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

/*
 This function is meant to update the user's friend available without making duplicates.
 it uses :
 self.friendList -> find current activity
 self.myFriends -> objectId of fetched users
 self.arrayOfId -> facebookId of fetched users
 facebookIds -> facebookId of all the user's friends
 self.sharingListfriends -> used to add new friends
*/
-(void)updateFriendFromFB {
    //set current user
    PFUser *currentUser = [PFUser currentUser];
    
    //query for user with activity with current
    PFQuery *queryForUser = [PFQuery queryWithClassName:AAActivityClassKey];
    [queryForUser whereKey:AAActivityFromUserKey equalTo:currentUser];
    [queryForUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendList removeAllObjects];
        //save & enumerate user found
        [self.friendList addObjectsFromArray:objects];
        [self.friendList enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
            //get back Ids of the users and save them in self.myFriends
            PFObject *friend = user;
            PFUser *friendUser = [friend objectForKey:AAActivityToUserKey];
            PFUser *userToGetId = [PFQuery getUserObjectWithId:friendUser.objectId];
            [self.myFriends addObject:userToGetId];
        }];
        //Now get back all the Facebook id from Users & save them in self.arrayOfId
        self.arrayOfId = [[NSMutableArray alloc] initWithCapacity:[self.myFriends count]];
        [self.arrayOfId removeAllObjects];
        for (PFUser *userForId in self.myFriends) {
            [self.arrayOfId addObject:userForId[@"facebookId"]];
        }
        
        //start a facebook connection
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSArray *data = [result objectForKey:@"data"];
                if (data) {
                    //Create an Array facebookIds and get back all the facebook ids of the user friend's
                    NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
                    [facebookIds removeAllObjects];
                    for (NSDictionary *friendData in data) {
                        if (friendData[@"id"]) {
                            [facebookIds addObject:friendData[@"id"]];
                            }
                    }
                    //Enumerate arrayOfId for each entry we enumerate the facebookIds array and check if the id exist, if it does, we delete the entry from the facebookIds array so we now just have an array with the facebook id's of Users non already known. With this method if there is no new friend for the current user the facebookIds array will be empty !
                    [self.arrayOfId enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx, BOOL *stop) {
                        [facebookIds enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx, BOOL *stop) {
                            if ([obj1 isEqual:obj2]) {
                                [facebookIds removeObject:obj2];
                            }
                        }];
                    }];

                    //we check and delete the current user from the array
                    [[AACache sharedChache] setFacebookFriends:facebookIds];
                    if (currentUser){
                        if ([currentUser objectForKey:AAUserFacebookIDKey]) {
                            [currentUser removeObjectForKey:AAUserFacebookIDKey];
                        }
                        
                        //and now we add all the new users and create a user activity =) the query will be nil if facebookIds is empty !
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
                                    //lets reload the array with all the friends user's
                                    [self updateFriendArray];

                                    
                                }];
                            }
                        }];
                    }
                }
            }
        }];

    }];
    
    
}



- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object{
    
    
    static NSString *Cellidentifier =  @"Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier forIndexPath:indexPath];
    
    //create a PFObject Friend comming for each row of the self.friendArray
    PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
    
    //create a PFUser for each of them
    self.friendInTable = [friend objectForKey:@"toUser"];
    
    cell.textLabel.text = self.friendInTable[@"name"];
    
    
    [self.selectedFriends enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger idx, BOOL *stop) {
        NSLog(@"user : %@ et friendIntable : %@", user, self.friendInTable);
        if ([user.objectId isEqual:self.friendInTable.objectId]) {
             cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
       
    }];
    
    NSLog(@"self.selected Friends : %@", self.selectedFriends);
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
        self.friendInTable = [friend objectForKey:@"toUser"];
        [self.selectedFriends addObject:self.friendInTable];
        NSLog(@"self.selectedfriend : %@", self.selectedFriends);
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
        self.friendInTable = [friend objectForKey:@"toUser"];
        NSLog(@"self.selected : %@  &&&& self.friendInTable : %@", self.selectedFriends, self.friendInTable);
        [self.selectedFriends removeObjectIdenticalTo:self.friendInTable];
         NSLog(@"self.selectedfriend : %@", self.selectedFriends);
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
