//
//  AAListViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAListViewController.h"
#import "AAHomeViewController.h"




@interface AAListViewController () <AAFFriendPickerTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

@property (strong, nonatomic) NSMutableArray *myList;
@property (strong, nonatomic) NSMutableArray *selectedFriends;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *titleLabel;

@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) PFObject *theNewList;
@property (strong, nonatomic) PFRelation *relation;



@end

@implementation AAListViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray *)myList
{
    if (!_myList) {
        _myList = [[NSMutableArray alloc] init];
    }
    return _myList;
}

-(NSMutableArray *)friendsPicked {
    if (!_selectedFriends) {
        _selectedFriends = [[NSMutableArray alloc] init];
    }
    
    return _selectedFriends;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self.selectedFriends removeAllObjects];
    
    self.textView.text = nil;
    self.titleLabel.delegate = self;
    
    
    // Do any additional setup after loading the view.
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
    
    PFUser *currentUser = [PFUser currentUser];
    
    self.theNewList = [PFObject objectWithClassName:AAListClassKey];
    
    [self.theNewList setObject:self.textView.text forKey:AAListTextKey];
    [self.theNewList setObject:self.titleLabel.text forKey:AAListTitleKey];
    [self.theNewList setObject:currentUser forKey:AAListUserKey];
    
    for (PFUser *user in self.selectedFriends) {
        self.relation = [self.theNewList relationForKey:@"Writer"];
        [self.relation addObject:user];
        
    }
    
    self.relation = [self.theNewList relationForKey:@"Writer"];
    [self.relation addObject:currentUser];
    
    
    [self.theNewList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else {
            NSLog(@"erreur : %@", error);
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.titleLabel resignFirstResponder];
    return YES;
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listToFriendPickSegue"]) {
        
        if ([segue.destinationViewController isKindOfClass:[AAFFriendPickerTableViewController class]]) {
            AAFFriendPickerTableViewController *pickerSegue = segue.destinationViewController;
            pickerSegue.delegate = self;
        }
    }
}





#pragma mark - Delegate

-(void)didPickFriends:(NSMutableArray *)friendsPicked{
    NSLog(@"Plop");
    self.selectedFriends = friendsPicked;
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
