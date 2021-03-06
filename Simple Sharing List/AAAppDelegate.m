//
//  AAAppDelegate.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 31/07/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAAppDelegate.h"

@implementation AAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Parse & Facebook Initialization
    
    [Parse setApplicationId:@"C0gpDdmNPFNz9pv3aD6mbkOFjHsUOEexM6B8FN9N"
                  clientKey:@"9F3hmxo2zofbEqqGsqHr2CofWx4snebYC1iqeydD"];
    
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if(application.applicationIconBadgeNumber !=0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:107.0/256.0 green:145.0/256.0 blue:35.0/256.0 alpha:1.0]];
    
    PFACL *defaultACl = [PFACL ACL];
    [defaultACl setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACl withAccessForCurrentUser:YES];
    
    [FBFriendPickerViewController class];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
