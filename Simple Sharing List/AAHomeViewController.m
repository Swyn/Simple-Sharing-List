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


@end

@implementation AAHomeViewController



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
}

#pragma mark - initial Query

-(PFQuery *)queryForTable
{
        PFUser *currentUser = [PFUser currentUser];
    
//    PFQuery *queryForSelf = [PFQuery queryWithClassName:self.parseClassName];
//    [queryForSelf whereKey:@"user" equalTo:currentUser];
    
    PFQuery *queryForFriends = [PFQuery queryWithClassName:self.parseClassName];
//    [queryForFriends whereKey:@"friend" equalTo:[[currentUser] objectId]];
    
    
    
//    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[queryForSelf, queryForFriends]];
    
    return queryForFriends;
    
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



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [object objectForKey:self.textKey];
    
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
