//
//  AAOldViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAOldViewController.h"

@interface AAOldViewController ()

@property (strong, nonatomic) IBOutlet UITextField *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *shareWithButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;



@end

@implementation AAOldViewController

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
    [self updateLabels];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender{
    
    PFQuery *query = [PFQuery queryWithClassName:@"AllLists"];
    [query getObjectInBackgroundWithId:self.oldList.objectId block:^(PFObject *object, NSError *error) {
        object[kAATextViewTitleKey] = self.titleLabel.text;
        object[kAAUserTextViewClassKey] = self.textView.text;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
   
}
- (IBAction)shareWithButtonPressed:(UIButton *)sender {
}

-(void)updateLabels
{
    self.titleLabel.text = [self.oldList objectForKey:kAATextViewTitleKey];
    self.textView.text = [self.oldList objectForKey:kAAUserTextViewClassKey];
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
