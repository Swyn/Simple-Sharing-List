//
//  AAFBFriendPickerTableViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 29/09/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAFFriendPickerTableViewController.h"


@interface AAFFriendPickerTableViewController ()


@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;


@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *myFriends;

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *arrayOfId;
@property (strong, nonatomic) NSMutableArray *simpleSharingListFriends;

@property (strong, nonatomic) PFUser *friendInTable;

@end

@implementation AAFFriendPickerTableViewController

-(NSMutableArray *)friendList {
    if (!_friendList) {
        _friendList = [[NSMutableArray alloc] init];
    }
    
    return _friendList;
}

-(NSMutableArray *)myFriends {
    if (!_myFriends){
        _myFriends = [[NSMutableArray alloc] init];
    }
    return _myFriends;
}

-(NSMutableArray *)selectedFriends{
    if (!_selectedFriends) {
        _selectedFriends = [[NSMutableArray alloc] init];
    }
    return _selectedFriends;
}

-(id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = AAActivityClassKey;
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
    }
    return self;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self updateFriendFromFB];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    NSLog(@"error : %@", [error localizedDescription]);
    if (!error) {
        [self.tableView reloadData];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friendsArray count];
}

-(void)updateFriendArray {
    PFQuery *friendArray = [PFQuery queryWithClassName:AAActivityClassKey];
    [friendArray whereKey:AAActivityFromUserKey equalTo:[PFUser currentUser]];
    [friendArray includeKey:AAActivityToUserKey];
    [friendArray findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendsArray removeAllObjects];
        self.friendsArray = [objects mutableCopy];
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
        [self.arrayOfId removeAllObjects];
        for (PFUser *userForId in self.myFriends) {
            [self.arrayOfId addObject:userForId[@"facebookId"]];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSArray *data = [result objectForKey:@"data"];
                if (data) {
                    NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
                    [facebookIds removeAllObjects];
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


-(PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIndetifier = @"friendCell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndetifier forIndexPath:indexPath];
    
    PFObject *friend = [self.friendsArray objectAtIndex:indexPath.row];
    self.friendInTable = [friend objectForKey:@"toUser"];
    
    cell.textLabel.text = self.friendInTable[@"name"];
    
    return cell;

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        PFObject *friend = [self.friendsArray objectAtIndex:indexPath.row];
        self.friendInTable = [friend objectForKey:@"toUser"];
        [self.selectedFriends addObject:self.friendInTable];
        
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.selectedFriends objectAtIndex:indexPath.row]];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Action Buttons

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)shareButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate didPickFriends:self.selectedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
