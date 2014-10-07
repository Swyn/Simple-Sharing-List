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



@end

@implementation AAFFriendPickerTableViewController



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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self updateFriendArray];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"nombre d'amis : %lu", [self.friendsArray count]);
    return [self.friendsArray count];
    
    
}

-(void)updateFriendArray {
    PFQuery *friendArray = [PFQuery queryWithClassName:AAActivityClassKey];
    [friendArray whereKey:AAActivityFromUserKey equalTo:[PFUser currentUser]];
    [friendArray includeKey:AAActivityToUserKey];
    [friendArray findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendsArray removeAllObjects];
        self.friendsArray = [objects mutableCopy];
        NSLog(@"friends array : %@", self.friendsArray);
        [self.tableView reloadData];
    }];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIndetifier = @"friendCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndetifier forIndexPath:indexPath];
    
    PFObject *friend = [self.friendsArray objectAtIndex:indexPath.row];
    PFUser *friendInTable = [friend objectForKey:@"toUser"];

    cell.textLabel.text = friendInTable[@"name"];
    
    if ([self.selectedFriends containsObject:[self.friendsArray objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:[self.friendsArray objectAtIndex:indexPath.row]];
        
        NSLog(@"%@", self.selectedFriends);
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.selectedFriends objectAtIndex:indexPath.row]];
        NSLog(@"%@", self.selectedFriends);
        
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
