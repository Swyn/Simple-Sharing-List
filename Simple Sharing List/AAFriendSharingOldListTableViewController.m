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

@property (strong, nonatomic) PFUser *friendInTable;

@end

@implementation AAFriendSharingOldListTableViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self updateFriendArray];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of sections.
    NSLog(@"nombre d'amis : %lu", [self.friendArray count]);
    return [self.friendArray count];
}

-(void)updateFriendArray {
    PFQuery *friendArray = [PFQuery queryWithClassName:AAActivityClassKey];
    [friendArray whereKey:AAActivityFromUserKey equalTo:[PFUser currentUser]];
    [friendArray includeKey:AAActivityToUserKey];
    [friendArray findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendArray removeAllObjects];
        self.friendArray = [objects mutableCopy];
        NSLog(@"friends array : %@", self.friendArray);
        [self.tableView reloadData];
    }];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *Cellidentifier =  @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Cellidentifier forIndexPath:indexPath];
    
    PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
    PFUser *friendInTable = [friend objectForKey:@"toUser"];
    cell.textLabel.text = friendInTable[@"name"];
    
  
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        PFObject *friend = [self.friendArray objectAtIndex:indexPath.row];
        self.friendInTable = [friend objectForKey:@"toUser"];
        [self.selectedFriends addObject:self.friendInTable];
        NSLog(@"self.selected friends : %@", self.selectedFriends);
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.selectedFriends objectAtIndex:indexPath.row]];
        NSLog(@"self.selected friends : %@", self.selectedFriends);

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancelBarButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)shareBarButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate didPickFriend:self.selectedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
