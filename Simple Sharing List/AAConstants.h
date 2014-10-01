//
//  AAConstants.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AAConstants : NSObject



#pragma mark - NSUserDefaults
extern NSString *const AAUserDefaultsActivityLastRefreshKey;
extern NSString *const AAUserDefaultsCacheFacebookFriendsKey;


#pragma mark - Notifications
// add notifications


#pragma mark - Installation Key
extern NSString *const AAInstalationUserKey;


#pragma mark - PFObject Activity Class
//Class key
extern NSString *const AAActivityClassKey;

//Fields keys
extern NSString *const AAActivityTypeKey;
extern NSString *const AAActivityFromUserKey;
extern NSString *const AAActivityToUserKey;
extern NSString *const AAActivityListKey;

//Type Value
extern NSString *const AAActivityTypeShared;
extern NSString *const AAActivityTypeJoined;

#pragma mark - PFObject User Class
//Fields keys
extern NSString *const AAUserNameKey;
extern NSString *const AAUserFacebookIDKey;
extern NSString *const AAUserPhotoIDKey;
extern NSString *const AAUserProfilePictureKey;
extern NSString *const AAUserFacebookFriendsKey;
extern NSString *const AAUSerProfilePicSmallKey;


#pragma mark - PFObject List Class
//Class key
extern NSString *const AAListClassKey;

//keys
extern NSString *const AAListUserKey;
extern NSString *const AAListTitleKey;
extern NSString *const AAListTextKey;
extern NSString *const AAListFriendsKey;

#pragma mark - Cached List Attributes
//keys
extern NSString *const kAAListAttributesShareCountKey;
extern NSString *const kAAListAttributesSharersKey;

#pragma mark - Cached User Attributes
//keys
extern NSString *const kAAUserAttributesListCountKey;
extern NSString *const kAAUserAttributesListIsSharedWithCurrentUser;



@end
