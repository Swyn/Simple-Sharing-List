//
//  AAConstants.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 02/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AAConstants.h"

@implementation AAConstants

#pragma mark - NSUserDefaults
NSString *const AAUserDefaultsActivityLastRefreshKey  = @"com.parse.SimpleSharingList.userDefaults.activity.lastRefresh";
NSString *const AAUserDefaultsCacheFacebookFriendsKey = @"com.parse.SimpleSharingList.userDefaults.cache.facebookFriends";


#pragma mark - Notifications
// add notifications


#pragma mark - Installation Key
NSString *const AAInstalationUserKey = @"user";


#pragma mark - PFObject Activity Class
//Class key
NSString *const AAActivityClassKey = @"Activity";

//Fields keys
NSString *const AAActivityTypeKey     = @"type";
NSString *const AAActivityFromUserKey = @"fromUser";
NSString *const AAActivityToUserKey   = @"toUser";
NSString *const AAActivityListKey     = @"list";

//Type Value
NSString *const AAActivityTypeShared = @"shared";
NSString *const AAActivityTypeJoined = @"joined";


#pragma mark - PFObject User Class
//Fields keys
NSString *const AAUserNameKey            = @"name";
NSString *const AAUserFacebookIDKey      = @"facebookId";
NSString *const AAUserPhotoIDKey         = @"photoId";
NSString *const AAUserProfilePictureKey  = @"profilePicture";
NSString *const AAUSerProfilePicSmallKey = @"profilePictureSmall";
NSString *const AAUserFacebookFriendsKey = @"facebookFriends";


#pragma mark - PFObject List Class
//Class key
NSString *const AAListClassKey = @"List";

//keys
NSString *const AAListUserKey =  @"user";
NSString *const AAListTitleKey =  @"title";
NSString *const AAListTextKey =  @"text";
NSString *const AAListFriendsKey = @"friends";

#pragma mark - Cached List Attributes
//keys
NSString *const kAAListAttributesShareCountKey = @"shareCount";
NSString *const kAAListAttributesSharersKey    = @"sharers";

#pragma mark - Cached User Attributes
//keys
NSString *const kAAUserAttributesListCountKey                = @"listCount";
NSString *const kAAUserAttributesListIsSharedWithCurrentUser = @"isSharedWithCurrentUser";

@end
