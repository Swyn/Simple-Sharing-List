//
//  AACache.h
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 22/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AACache : NSObject

+(id)sharedChache;

-(void)clear;
-(void)setAttributesForList:(PFObject *)list sharedWith:(NSArray *)sharers;
-(NSDictionary *)attributesForList:(PFObject *)list;
-(NSArray *)sharersForList:(PFObject *)list;
-(NSNumber *)shareCountForList:(PFObject *)list;
-(void)incrementSharersCountForList:(PFObject *)list;
-(void)decrementSharersCountForLIst:(PFObject *)list;


-(NSDictionary *)attributesForUser:(PFUser *)user;
-(NSNumber *)listCountForUser:(PFUser *)user;
-(BOOL)sharedStatusForUser:(PFUser *)user;
-(void)setListCount:(NSNumber *)count user:(PFUser *)user;
-(void)setSharedStatus:(BOOL)shared user:(PFUser *)user;

-(void)setFacebookFriends:(NSArray *)friends;
-(NSArray *)facebookFriends;

@end
