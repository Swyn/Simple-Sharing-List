//
//  AACache.m
//  Simple Sharing List
//
//  Created by Alexandre ARRIGHI on 22/08/2014.
//  Copyright (c) 2014 Alexandre ARRIGHI. All rights reserved.
//

#import "AACache.h"

@interface AACache()

@property (strong, nonatomic)NSCache *cache;
-(void)setAttributes:(NSDictionary *)attributes forList:(PFObject *)list;

@end

@implementation AACache
@synthesize cache;


#pragma mark - Init

+(id)sharedChache{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - AACache

-(void)clear {
    [self.cache removeAllObjects];
}

#pragma mark - AACache For List

-(void)setAttributesForList:(PFObject *)list sharedWith:(NSArray *)sharers
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                @([sharers count]), kAAListAttributesShareCountKey,
                                sharers, kAAListAttributesSharersKey,
                                nil];
    
    [self setAttributes:attributes forList:list];
}

-(NSDictionary *)attributesForList:(PFObject *)list {
    NSString *key = [self keyForList:list];
    return [self.cache objectForKey:key];
}

-(NSNumber *)shareCountForList:(PFObject *)list {
    NSDictionary *attributes = [self attributesForList:list];
    if (attributes) {
        return [attributes objectForKey:kAAListAttributesShareCountKey];
    }
    return [NSNumber numberWithInt:0];
}

-(NSArray *)sharersForList:(PFObject *)list {
    NSDictionary *attributes = [self attributesForList:list];
    if (attributes) {
        return [attributes objectForKey:kAAListAttributesSharersKey];
    }
    
    return [NSArray array];
}

-(void)incrementSharersCountForList:(PFObject *)list{
    NSNumber *sharerCount = [NSNumber numberWithInt:[[self shareCountForList:list] intValue] +1];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForList:list]];
    [attributes setObject:sharerCount forKey:kAAListAttributesShareCountKey];
    [self setAttributes:attributes forList:list];
}

-(void)decrementSharersCountForLIst:(PFObject *)list {
    NSNumber *sharerCount = [NSNumber numberWithInt:[[self shareCountForList:list] intValue] -1];
    if ([sharerCount intValue] < 0) {
        return;
    }
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForList:list]];
    [attributes setObject:sharerCount forKey:kAAListAttributesShareCountKey];
    [self setAttributes:attributes forList:list];
}

#pragma mark - AACache For User

-(void)setAttributesForUser:(PFUser *)user listCount:(NSNumber *)count {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                count, kAAUserAttributesListCountKey,
                                nil];
    [self setAttributes:attributes forUser:user];
}

-(NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

-(NSNumber *)listCountForUser:(PFUser *)user{
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *listCount = [attributes objectForKey:kAAUserAttributesListCountKey];
        if (listCount) {
            return listCount;
        }
    }
    return [NSNumber numberWithInt:0];
}

-(void)setListCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kAAUserAttributesListCountKey];
    [self setAttributes:attributes forUser:user];
}

-(void)setFacebookFriends:(NSArray *)friends {
    NSString *key = AAUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSArray *)facebookFriends {
    NSString *key = AAUserDefaultsCacheFacebookFriendsKey;
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    return friends;
}

-(void)setSharedStatus:(BOOL)sharing user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:[NSNumber numberWithBool:sharing] forKey:kAAUserAttributesListIsSharedWithCurrentUser];
    [self setAttributes:attributes forUser:user];
    
}

-(BOOL)sharedStatusForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    if (attributes) {
        NSNumber *sharingStatus = [attributes objectForKeyedSubscript:kAAUserAttributesListIsSharedWithCurrentUser];
        if (sharingStatus) {
            return [sharingStatus boolValue];
        }
    }
    
    return NO;
}

#pragma mark - Helper

- (void)setAttributes:(NSDictionary *)attributes forList:(PFObject *)list{
    NSString *key = [self keyForList:list];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

-(NSString *)keyForList:(PFObject *)list {
    return [NSString stringWithFormat:@"list_%@", [list objectId]];
    }

-(NSString *)keyForUser:(PFUser *)user{
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
