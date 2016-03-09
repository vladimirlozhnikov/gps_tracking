//
//  DBUser+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBUser.h"
#import <CoreLocation/CoreLocation.h>
#import "UpdateInfo.h"

@interface DBUser (Methods)

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak, readonly) UpdateInfo* updateInfo;
@property (nonatomic) BOOL backgroundModeActive;
@property (nonatomic, copy) void(^onUpdateCoordinatesBlock)();

@property (nonatomic) NSUInteger status;
@property (nonatomic) NSTimer* pinTimer;
@property (nonatomic) BOOL isUpdatePinActive;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) BOOL previousValue;

+ (DBUser*) userWithDictionary:(NSDictionary*)dictionary;
+ (DBUser*) userWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email;
- (void) registerWithSuccess:(void(^)(NSDictionary* response))onSuccess onError:(void(^)(NSString* error))onError saveAvatar:(BOOL)saveAvatar;
- (void) updateWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (void) abuseWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (NSDictionary*) dictionaryPresentation;
- (void) addMessagesWithArray:(NSArray*)messages;

- (NSString*) distanceFromLocation:(CLLocation*)fromLocation kmHOnly:(BOOL)kmHOnly;

- (void) updatePinIsActive:(BOOL)active;
- (void) imageInBackground:(UIImageView*)imageView;
- (void) addMyGroup:(DBGroup*)group;

-(void) onUpdatePin:(NSTimer*)timer;
- (UIImage*) imageInMarker;

@end
