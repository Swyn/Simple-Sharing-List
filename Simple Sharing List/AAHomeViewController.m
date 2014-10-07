//
//  AAHomeViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAHomeViewController.h"
#import "AAListViewController.h"
#import "AAOldViewController.h"
#import "AAConstants.h"


@interface AAHomeViewController ()

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *listView;


@end

@implementation AAHomeViewController


-(NSMutableArray *)friendList {
    if (!_friendList) {
        _friendList = [[NSMutableArray alloc] init];
    }
    return _friendList;
}

-(NSMutableArray *)listView{
    if (!_listView){
        _listView = [[NSMutableArray alloc]init];
    }
    return _listView;
}

-(id)initWithCoder:(NSCoder *)aCoder
{
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = AAListClassKey;
        self.textKey = AAListTitleKey;
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)refreshTable:(NSNotification *)notification
{
    [self loadObjects];
    
}


- (void)viewDidLoad

{

    [super viewDidLoad];
    [self updateListTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTable:) name:@"refreshTable" object:nil];
    // Do any additional setup after loading the view.
    
    
    
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    NSLog(@"error : %@", [error localizedDescription]);
    if (!error) {
        [self updateListTable];
    }
}




#pragma mark - initial Query

-(void)updateListTable
{
    [self.friendList removeAllObjects];
    NSLog(@"bonjour");
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"user" equalTo:currentUser];
    
    PFQuery *queryForShared = [PFQuery queryWithClassName:AAActivityClassKey];
    [queryForShared whereKey:AAActivityToUserKey equalTo:currentUser];
    [queryForShared includeKey:@"objectId"];
    [queryForShared findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.friendList removeAllObjects];
        self.friendList = [objects mutableCopy];
        NSLog(@"self.friendList : %@", self.friendList);
        
    }];
    
    PFQuery *sharedList = [PFQuery queryWithClassName:self.parseClassName];
    int i;
    for (i = 0 ; i < [self.friendList count] ; i++) {
    [sharedList whereKey:AAActivityTypeJoined containsString:[self.friendList objectAtIndex:i]];
    }
    
    PFQuery *joinQuery = [PFQuery orQueryWithSubqueries:@[query, sharedList]];
    [joinQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            [self.listView removeAllObjects];
            self.listView = [objects mutableCopy];
            NSLog(@"listView : %@", self.listView);
            [self.tableView reloadData];
        }
    }];
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToOldListSegue"]) {
        
        AAOldViewController *nextVC = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        nextVC.oldList = [self.objects objectAtIndex:indexPath.row];
       

    }
}

#pragma mark - UITableView DataSources

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listView count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    PFObject *list = [self.listView objectAtIndex:indexPath.row];
    
    cell.textLabel.text = list[@"title"];
    return cell;
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
