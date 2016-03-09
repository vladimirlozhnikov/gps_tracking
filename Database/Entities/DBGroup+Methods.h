//
//  DBGroup+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBGroup.h"
#import "DBCountry+Methods.h"
#import "DBCity+Methods.h"
#import "DBUser+Methods.h"
#import "DBMessage+Methods.h"

@interface DBGroup (Methods)

@property (nonatomic, weak) DBUser *owner;
@property (nonatomic, weak) NSMutableArray *users;
@property (assign) NSInteger usersCount;
@property (readonly) BOOL isOwner;

+ (DBGroup*) groupWithName:(NSString*)name description:(NSString*)description country:(DBCountry*)country city:(DBCity*)city owner:(DBUser*)owner isOpen:(BOOL)isOpen color:(UIColor*)color;
+ (DBGroup*) groupWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) dictionaryPresentation;

- (void) updateUsersWithCriteria:(NSString*)criteria withSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;
- (void) updatePinsForUsersWithSuccess:(void(^)())onSuccess;

- (void) joinWithTicket:(NSString*)ticket onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;
- (void) leaveWithSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;
- (void) sendMessage:(DBMessage*)message toUsers:(NSArray*)toUsers onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;
- (void) updateWithSuccess:(void(^)())onSuccess onError:(void (^)(NSString *))onError;
- (NSArray*) filterUsersWithCriteria:(NSString*)criteria;
- (void) addUsersWithArray:(NSArray*)users;
- (NSArray*) removeUsersWithArray:(NSArray*)usersIDs;
- (DBUser*) userWithUserId:(NSString*)userId;

@end
