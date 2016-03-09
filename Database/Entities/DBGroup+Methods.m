//
//  DBGroup+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBGroup+Methods.h"
#import "Model.h"
#import "PPDbManager.h"
#import "ImageUtils.h"
#import "Pin.h"
#import "TypeUtils.h"
#import "DBColor.h"
#import "Color.h"
#import "Base64.h"

@implementation DBGroup (Methods)

typedef void(^OnSuccessSimple)();
typedef void(^OnSuccess)(NSArray* users);
typedef void(^OnError)(NSString* error);

- (BOOL) isOwner
{
	return [DELEGATE.me.index isEqualToString:self.owner.index];
}

- (NSInteger) usersCount
{
    return usersCount;
}

- (void) setUsersCount:(NSInteger)theUsersCount
{
    usersCount = theUsersCount;
}

+ (DBGroup*) groupWithName:(NSString*)name description:(NSString*)description country:(DBCountry*)country city:(DBCity*)city owner:(DBUser*)owner isOpen:(BOOL)isOpen color:(UIColor*)theColor
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [theColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    DBColor* color = [PPDbManager objectForEntityName:@"DBColor"];
    color.red = [NSNumber numberWithFloat:red];
    color.green = [NSNumber numberWithFloat:green];
    color.blue = [NSNumber numberWithFloat:blue];
    
	DBGroup* group = [PPDbManager objectForEntityName:@"DBGroup"];
    
	group.name = name;
	group.desc = description;
	group.country = country;
	group.city = city;
	group.owner = owner;
	group.isOpen = [NSNumber numberWithBool:isOpen];
	group.color = color;
    
	return group;
}

+ (DBGroup*) groupWithDictionary:(NSDictionary*)dictionary
{
    DBGroup* group = [PPDbManager itemForEntitiNameAndCriteria:@"DBGroup" withCriteria:[NSString stringWithFormat:@"ind LIKE '%@'", [dictionary objectForKey:@"groupid"]]];
    
    if (!group)
    {
        group = [PPDbManager objectForEntityName:@"DBGroup"];
    }
    
    group.ind = [dictionary objectForKey:@"groupid"];
    group.name = [dictionary objectForKey:@"name"];
    group.desc = [dictionary objectForKey:@"description"];
    group.isOpen = [NSNumber numberWithBool:[[dictionary objectForKey:@"is_open"] boolValue]];
    group.ticket = [dictionary objectForKey:@"ticket"];
    group.email = [dictionary objectForKey:@"user_email"];
    group.firstName = [dictionary objectForKey:@"user_name"];
    group.lastName = [dictionary objectForKey:@"user_surname"];
    group.nickname = [dictionary objectForKey:@"user_nickname"];
    group.usersCount = [[dictionary objectForKey:@"count_of_users"] integerValue];
    
    //NSLog(@"%@", dictionary);
    
    /*NSString* hexColor = [dictionary objectForKey:@"color"];
    if (hexColor)
    {
        UIColor* c = [Color colorWithHexString:hexColor];
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        [c getRed:&red green:&green blue:&blue alpha:&alpha];
        
        DBColor* color = [PPDbManager objectForEntityName:@"DBColor"];
        color.red = [NSNumber numberWithFloat:red];
        color.green = [NSNumber numberWithFloat:green];
        color.blue = [NSNumber numberWithFloat:blue];
        
        group.color = color;
    }*/
    
    group.country = [DBCountry countryWithDictionary:[dictionary objectForKey:@"country"]];
    group.city = [DBCity cityWithDictionary:[dictionary objectForKey:@"city"]];
    DBUser* user = [DBUser userWithDictionary:[dictionary objectForKey:@"owner"]];
    group.owner = user;
    
	return group;
}

- (NSDictionary*) dictionaryPresentation
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
	[dictionary setObject:self.name forKey:@"name"];
	[dictionary setObject:[self.ind length] > 0 ? self.ind : @"" forKey:@"groupid"];
	[dictionary setObject:[self.desc length] > 0 ? self.desc : @"" forKey:@"description"];
	[dictionary setObject:self.isOpen forKey:@"is_open"];
	[dictionary setObject:[self.ticket length] > 0 ? self.ticket : @"" forKey:@"ticket"];
	[dictionary setObject:[self.email length] > 0 ? self.email : @"" forKey:@"user_email"];
	[dictionary setObject:[self.firstName length] > 0 ? self.firstName : @"" forKey:@"user_name"];
	[dictionary setObject:[self.lastName length] > 0 ? self.lastName : @"" forKey:@"user_surname"];
	[dictionary setObject:[self.nickname length] > 0 ? self.nickname : @"" forKey:@"user_nickname"];
	[dictionary setObject:[self.country dictionaryPresentation] forKey:@"country"];
	[dictionary setObject:[self.city dictionaryPresentation] forKey:@"city"];
    [dictionary setObject:[self.owner dictionaryPresentation] forKey:@"owner"];
	
	[dictionary setObject:[Base64 encode:self.imageFlag] forKey:@"flag"];
	NSString* color = [Color hexStringWithColor:[UIColor blueColor]];
	[dictionary setObject:color forKey:@"color"];
    
	return dictionary;
}

- (NSArray*) parseUsers:(NSArray*)array
{
	NSMutableArray* result = [NSMutableArray array];
	DBUser* me = DELEGATE.me;
    
	for (NSDictionary* userInfo in array)
	{
		DBUser* user = [DBUser userWithDictionary:userInfo];
		[result addObject:[user isEqual:me] ? me :user];
	}
    
	return result;
}

- (NSArray*) parseUserCoordinates:(NSArray*)array
{
	NSMutableArray* result = [NSMutableArray array];
	for (NSDictionary* info in array)
    {
        [result addObject:[Pin pinWithDictionary:info]];
    }
	
	return result;
}

- (void) updateUsersWithCriteria:(NSString*)criteria withSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
    //NSLog(@"usersWithCriteria");
	[self usersWithCriteria:@"" isFullInfo:YES withSuccess:^(NSArray *users)
     {
         //NSLog(@"updatePinsForUsersWithSuccess");
         [self updatePinsForUsersWithSuccess:^
          {
              onSuccess();
          }];
	 } onError:^(NSString *error)
     {
         NSLog(@"cannot update users");
         onError(error);
     }];
}

- (void) usersWithCriteria:(NSString*)criteria isFullInfo:(BOOL)fullInfo withSuccess:(void(^)(NSArray* users))onSuccess onError:(void(^)(NSString* error))onError
{	
	NSString* path = [NSString stringWithFormat:@"groups/%@/users", [self ind]];
	NSDictionary* params = @{@"criteria": criteria, @"fullInfo" : @(fullInfo)};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         //NSLog(@"response: %@", result);
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             onError([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         NSArray* objects = nil;
         if (fullInfo)
         {
             [self.users removeAllObjects];
             objects = [self parseUsers:[result objectForKey:@"users"]];
             for (DBUser* u in objects)
             {
                 BOOL exists = NO;
                 for (DBUser* u1 in self.users)
                 {
                     if ([u1.index isEqualToString:u.index])
                     {
                         exists = YES;
                         break;
                     }
                 }
                 
                 if (!exists)
                 {
                     [self.users addObject:u];
                 }
             }
         }
         else
         {
             objects = [self parseUserCoordinates:[result objectForKey:@"gps"]];
         }
         
         onSuccess(objects);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failure, usersWithCriteria, response: %@", [operation responseString]);
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         
         onError([error localizedDescription]);
     }];
}

- (void) updatePinsForUsersWithSuccess:(void(^)())onSuccess
{
    //NSLog(@"usersWithCriteria");
	[self usersWithCriteria:@"" isFullInfo:NO withSuccess:^(NSArray* pins)
     {
         //NSLog(@"usersWithCriteria finished");
         for (DBUser* user in self.users)
         {
             for (Pin* pin in pins)
             {
                 if ([user.index isEqualToString:pin.userID])
                 {
                     user.coordinate = pin.coordinate;
                 }
             }
         }
         
         onSuccess();
     } onError:^(NSString *error)
     {
         NSLog(@"error occured");
         onSuccess(); //!!! counter pendedUpdatesCount must be decrease
     }];
}

- (void) updateWithSuccess:(void(^)())onSuccess onError:(void (^)(NSString*))onError
{
    NSString* path = [NSString stringWithFormat:@"groups/update/"];
    NSDictionary* params = @{@"group": [self dictionaryPresentation]};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             onError([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         onSuccess();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, updateWithSuccess, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (void) joinWithTicket:(NSString*)ticket onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
	NSString* path = [NSString stringWithFormat:@"groups/%@/join", self.ind];
    NSDictionary* params = @{@"ticket": ticket};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             NSString* description = [[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]];
             [DELEGATE.me updatePinIsActive:YES];
             onError(description);
             return;
         }
         
         onSuccess();
     }  failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, joinWithTicket, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (void) leaveWithSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
	NSString* path = [NSString stringWithFormat:@"groups/%@/leave", self.ind];
	[[Model sharedInstance].httpClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             NSString* description = [[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]];
             [DELEGATE.me updatePinIsActive:NO];
             onError(description);
             return;
         }
         
         [Model sharedInstance].updateManager.activeGroup = nil;
         [DELEGATE.me updatePinIsActive:NO];
         [[Model sharedInstance].updateManager pingIsActive:NO frequency:[Model sharedInstance].settings.requestsFrequency];
         
         onSuccess();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         [DELEGATE.me updatePinIsActive:NO];
         NSLog(@"failure, leaveWithSuccess, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

-(void) sendMessage:(DBMessage*)message toUsers:(NSArray*)toUsers onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
	NSMutableArray* content = [NSMutableArray array];
	for (DBUser* user in toUsers)
    {
        [content addObject:user.index];
    }
	
	NSString* path = [NSString stringWithFormat:@"groups/%@/message", self.ind];
	NSDictionary* params = @{@"message": [message dictionaryPresentation], @"users" : content};
    
    NSLog(@"%@", params);
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:path parameters:params success:^(AFHTTPRequestOperation* operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             NSString* description = [[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]];
             onError(description);
             
             return;
         }
         onSuccess();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, sendMessage, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (NSArray*) filterUsersWithCriteria:(NSString*)criteria
{
	NSPredicate* predicate = [NSPredicate predicateWithFormat:
							  @"(firstName contains[c] %@) OR "
							  "(lastName contains[c] %@) OR "
							  "(nickName contains[c] %@) OR "
							  "(email contains[c] %@) OR "
							  "(phoneNumber contains[c] %@)"
							  , criteria, criteria, criteria, criteria, criteria, nil];
    
	return [self.users filteredArrayUsingPredicate:predicate];
}

- (void) addUsersWithArray:(NSArray*)theUsers
{
	for (DBUser* u in theUsers)
	{
        BOOL exists = NO;
        for (DBUser* u1 in self.users)
        {
            if ([u1.index isEqualToString:u.index])
            {
                exists = YES;
                break;
            }
        }
        
        if (!exists)
        {
            [self.users addObject:u];
        }
	}
}

- (NSArray*) removeUsersWithArray:(NSArray*)usersIDs
{
	NSMutableArray* forRemove = [NSMutableArray array];
    
    for (NSString* userID in usersIDs)
    {
        for (DBUser* user in self.users)
        {
            if ([userID isEqualToString:user.index])
            {
                [forRemove addObject:user];
                [self.users removeObject:user];
                
                break;
            }
        }
    }
    
	return forRemove;
}

- (DBUser*) userWithUserId:(NSString*)userId
{
    for (DBUser* user in self.users)
    {
        if ([userId isEqualToString:user.index])
        {
            return user;
        }
    }
    
    return nil;
}

- (void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeObject:[self dictionaryPresentation]];
}

#pragma mark - Properties

- (DBUser*) owner
{
    return owner;
}

- (void) setOwner:(DBUser *)theOwner
{
    owner = theOwner;
}

- (NSMutableArray*) users
{
    if (!users)
    {
        users = [[NSMutableArray alloc] init];
    }
    
    return users;
}

- (void) setUsers:(NSMutableArray *)theUsers
{
    users = theUsers;
}

@end
