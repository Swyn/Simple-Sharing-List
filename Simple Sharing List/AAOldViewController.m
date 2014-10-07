//
//  AAOldViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAOldViewController.h"
#import "AAFriendSharingOldListTableViewController.h"

@interface AAOldViewController () <AAFriendSharingOldListTableViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *shareWithButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) NSMutableArray *myList;

@property (strong, nonatomic) NSMutableArray *selectedFriends;



@end

@implementation AAOldViewController

-(NSMutableArray *)selectedFriends {
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
    self.textView.text = nil;
    self.titleLabel.delegate = self;
    [self updateLabels];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender{
    
    PFQuery *query = [PFQuery queryWithClassName:AAListClassKey];
    [query getObjectInBackgroundWithId:self.oldList.objectId block:^(PFObject *object, NSError *error) {
        object[AAListTitleKey] = self.titleLabel.text;
        object[AAListTextKey] = self.textView.text;
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


- (IBAction)shareWithButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"listToFriendPickSegue" sender:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"listToFriendPickSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[AAFriendSharingOldListTableViewController class]]) {
            AAFriendSharingOldListTableViewController *pickerSegue = segue.destinationViewController;
            pickerSegue.delegate = self;
        }
    }
}

-(void)updateLabels
{
    self.titleLabel.text = [self.oldList objectForKey:AAListTitleKey];
    self.textView.text = [self.oldList objectForKey:AAListTextKey];
}

-(void)didPickFriend:(NSMutableArray *)friendPicked {
    self.selectedFriends = friendPicked;
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
