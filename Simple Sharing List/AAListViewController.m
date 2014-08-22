//
//  AAListViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAListViewController.h"
#import "AAHomeViewController.h"


@interface AAListViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

@property (strong, nonatomic) NSMutableArray *myList;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@property (strong, nonatomic) PFObject *theNewList;


@end

@implementation AAListViewController

-(NSMutableArray *)myList
{
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
    
    
    // Do any additional setup after loading the view.
    
}



-(void)checkForList
{
    //PFQuery *queryForList = [PFQuery queryWithClassName:@"Text"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
    
    
    
    
    self.theNewList = [PFObject objectWithClassName:@"AllLists"];
    
    [self.theNewList setObject:self.textView.text forKey:kAAUserTextViewClassKey];
    [self.theNewList setObject:self.titleLabel.text forKey:kAATextViewTitleKey];
    [self.theNewList setObject:self.userFBID forKey:kAAUserListShareSelfIdKey];
    [self.theNewList setObject:[PFUser currentUser] forKey:KAAUserUserKey];
    
    for (int x=0; x < [self.myList count]; x++) {
        
        [self.theNewList setObject:self.myList[x] forKey:kAAUserListShareKey];
    }
    
    [self.theNewList saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)shareWithButtonPressed:(UIButton *)sender {
    self.friendPickerController = [[FBFriendPickerViewController alloc] init];
    self.friendPickerController.title = @"Share With...";
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    [self.friendPickerController setDelegate:self];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

-(void)facebookViewControllerDoneWasPressed:(id)sender {
    
    
    for (id<FBGraphUser> user in self.friendPickerController.selection) {
        NSLog(@"%@", user.objectID);
        
        
        [self.myList addObject:[NSString stringWithFormat:@"%@", user.objectID]];
    }
    NSLog(@"%@", self.myList);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
