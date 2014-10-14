//
//  AALoginViewController.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 01/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AALoginViewController.h"
#import "AAUtility.h"
#import "Reachability.h"

@interface AALoginViewController (){
    NSMutableData *_data;
}
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation AALoginViewController

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
    
    self.activityIndicator.hidden = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
}

#pragma mark - Facebook Connection

-(void)updateInfos
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [self facebookRequestDidLoad:result];
            NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[PFUser currentUser] objectForKey:AAUserFacebookIDKey]]];
            NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
            [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
        } else
        {
            [self facebookRequestDidFailWithError:error];
        }
    }];
}

#pragma mark - NSURL Connection Data Delegate

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _data = [[NSMutableData alloc] init];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [AAUtility processFacebookProfilePictureData:_data];
}


#pragma mark - AppDelegate

-(BOOL)isParseReachable{
    return self.networkStatus != NotReachable;
}


- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"public_profile", @"user_friends"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if (!user){
            if (!error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else{
            [self updateInfos];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
        }
    }];
    
}

-(void)facebookRequestDidLoad:(id)result{
    PFUser *user = [PFUser currentUser];
    
    NSArray *data = [result objectForKey:@"data"];
    
    if(data){
        NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSDictionary *friendData in data ) {
            if (friendData[@"id"]){
                [facebookIds addObject:friendData[@"id"]];
            }
        }
        
        [[AACache sharedChache] setFacebookFriends:facebookIds];
        
        if (user) {
            if ([user objectForKey:AAUserFacebookFriendsKey]) {
                [user removeObjectForKey:AAUserFacebookFriendsKey];
            }
    
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:AAUserFacebookIDKey containedIn:facebookIds];
            
            self.simpleSharingListFriends = [[NSMutableArray alloc] init];
            
            [facebookFriendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [self.simpleSharingListFriends removeAllObjects];
                    [self.simpleSharingListFriends addObjectsFromArray:objects];
                    [self.simpleSharingListFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                        
                        PFObject *joinActivity = [PFObject objectWithClassName:AAActivityClassKey];
                        [joinActivity setObject:user forKey:AAActivityFromUserKey];
                        [joinActivity setObject:newFriend forKey:AAActivityToUserKey];
                        [joinActivity setObject:AAActivityTypeJoined forKey:AAActivityTypeKey];
                        
                        PFACL *joinACL = [PFACL ACL];
                        [joinACL setPublicReadAccess:YES];
                        joinActivity.ACL = joinACL;
                        
                        [joinActivity saveInBackground];
                    }];
                }
            }];
            [user saveEventually];
        }
    }
    else {
        if (user) {
            NSString *facebookName = result[@"name"];
            if (facebookName && [facebookName length] != 0) {
                [user setObject:facebookName forKey:AAUserNameKey];
                
            }else {
                [user setObject:@"Someone" forKey:AAUserNameKey];
            }
            NSString *facebookId = result[@"id"];
            if (facebookId && [facebookId length] != 0) {
                [user setObject:facebookId forKey:AAUserFacebookIDKey];
            }
            [user saveEventually];
        }
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
    
}

-(void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if([PFUser currentUser]){
        if ([PFUser currentUser]) {
            NSLog(@"The Facebook token was invalidated. Logging out?");
            
        }
    }
}











@end
