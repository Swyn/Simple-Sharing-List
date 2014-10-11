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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.listView removeAllObjects];
        [self.listView addObjectsFromArray:objects];
        [self.tableView reloadData];
    }];
    
    
}


#pragma mark - UITableView DataSources

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listView count];
}

-(PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    static NSString *simpleTableIdentifier = @"Cell";
    
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    
    
    PFObject *list = [self.listView objectAtIndex:indexPath.row];
    
    cell.textLabel.text = list[@"title"];
    return cell;
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"homeToOldListSegue"]) {
        
        
        
        AAOldViewController *nextVX = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        nextVX.oldList = [self.listView objectAtIndex:indexPath.row];
    
//    AAOldViewController *nextVC = segue.destinationViewController;
//    NSIndexPath *indexPath = sender;
//    nextVC.oldList = [self.listView  objectAtIndex:indexPath.row];
    
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"homeToOldListSegue" sender:indexPath];
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
