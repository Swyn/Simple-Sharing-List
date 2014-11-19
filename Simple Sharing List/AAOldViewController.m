//
//  AAOldViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAOldViewController.h"
#import "AAHomeViewController.h"

@interface AAOldViewController () <AAFriendSharingOldListTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *updateSharingButton;

@property (strong, nonatomic) NSMutableArray *myList;

@property (strong, nonatomic) NSMutableArray *selectedFriends;

@property (strong, nonatomic) PFObject *thisList;
@property (strong, nonatomic) PFRelation *oldRelationNew;



@end

@implementation AAOldViewController


-(NSMutableArray *)friendsPicked {
    if (!_selectedFriends) {
        _selectedFriends = [[NSMutableArray alloc]init];
    }
    return _selectedFriends;
}

-(NSMutableArray *)myList {
    if (!_myList) {
        _myList = [[NSMutableArray alloc] init];
    }
    return _myList;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.updateSharingButton.enabled = YES;
    self.textView.text = nil;
    self.titleLabel.delegate = self;
    
    
    
    [self.selectedFriends removeAllObjects];
    [self UpdateSharing];
    [self updateLabels];
   
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)UpdateSharing {
    PFRelation *relation = [self.oldList relationForKey:@"Writer"];
    PFQuery *query = [relation query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.myList addObjectsFromArray:objects];
    }];
    
}

- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender{
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:AAListClassKey];
    [query getObjectInBackgroundWithId:self.oldList.objectId block:^(PFObject *object, NSError *error) {
        
        object[AAListTitleKey] = self.titleLabel.text;
        object[AAListTextKey] = self.textView.text;
        
        [self.myList enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx, BOOL *stop) {
            self.oldRelationNew = [object relationForKey:@"Writer"];
            [self.oldRelationNew removeObject:obj1];
        }];
        
        for (PFUser *user in self.selectedFriends) {
            self.oldRelationNew = [object relationForKey:@"Writer"];
            [self.oldRelationNew addObject:user];
        }
        self.oldRelationNew = [object relationForKey:@"Writer"];
        [self.oldRelationNew addObject:currentUser];
    
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];

   
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.titleLabel resignFirstResponder];
    return YES;
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listToFriendPickSegue"]) {
        
        if ([segue.destinationViewController isKindOfClass:[AAFriendSharingOldListTableViewController class]]) {
            AAFriendSharingOldListTableViewController *pickerSegue = segue.destinationViewController;
            pickerSegue.friendsAlreadyPicked = [self.myList mutableCopy];
            pickerSegue.delegate = self;
        }
    }
}

-(void)updateLabels
{
    self.titleLabel.text = [self.oldList objectForKey:AAListTitleKey];
    self.textView.text = [self.oldList objectForKey:AAListTextKey];
}



-(void)didPickFriendForOldList:(NSMutableArray *)friendsPickedForOldList {
    self.selectedFriends = friendsPickedForOldList;
}

- (IBAction)updateSharingBarButtonPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"listToFriendPickSegue" sender:self];
}


@end
