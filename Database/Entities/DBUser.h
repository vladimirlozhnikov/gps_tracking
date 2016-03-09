//
//  DBUser.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 07.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "Protocol.h"

@class DBGroup, DBMessage;

@interface DBUser : NSManagedObject
{
    CLLocationDegrees lastLatitude;
	CLLocationDegrees lastLongitude;
    CLLocationCoordinate2D coordinate;
    BOOL backgroundModeActive;
    
    NSUInteger status;
    NSTimer* pinTimer;
    BOOL isUpdatePinActive;
    BOOL isBusy;
    BOOL previousValue;
    
    __strong UIActivityIndicatorView* activity;
    void (^onUpdateCoordinatesBlock)();
    __weak id <BackgroundActionsDelegate> delegate;
}

@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSData * imageAvatar;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * index;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * nickName;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSSet *messages;
@property (nonatomic, strong) NSSet *myGroups;

@property (weak) id <BackgroundActionsDelegate> delegate;
@end

@interface DBUser (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(DBMessage *)value;
- (void)removeMessagesObject:(DBMessage *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addMyGroupsObject:(DBGroup *)value;
- (void)removeMyGroupsObject:(DBGroup *)value;
- (void)addMyGroups:(NSSet *)values;
- (void)removeMyGroups:(NSSet *)values;

@end
