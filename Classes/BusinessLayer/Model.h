//
//  Model.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"
#import "Settings.h"
#import "AFNetworking.h"
#import "ErrorTranslator.h"
#import "Credentials.h"
#import "Locations.h"
#import "MyGroupsManager.h"
#import "MyMessagesManager.h"
#import "UpdatesManager.h"
#import "DBUser+Methods.h"

@class DBGroup;

@interface Model : NSObject
{
	BOOL _bLogged;
	__strong Settings* _settings;
	__strong AFHTTPClient* _httpClient;
	__strong ErrorTranslator* _errorTranslator;
    __strong Credentials* _credentials;
	__strong Locations* _locations;
	__strong MyGroupsManager* _myGroups;
	__strong MyMessagesManager* _myMessages;
	__strong UpdatesManager* _updateManager;
	
    NSInteger totalDownloadBytes;
    NSInteger totalUploadBytes;
}

@property (nonatomic, strong, readonly) ErrorTranslator* errorTranslator;
@property (nonatomic, strong, readonly) AFHTTPClient* httpClient;
@property (nonatomic, strong, readonly) Credentials* credentials;
@property (nonatomic, strong, readonly) Locations* locations;
@property (nonatomic, strong, readonly) MyGroupsManager* myGroups;
@property (nonatomic, strong, readonly) MyMessagesManager* myMessages;
@property (nonatomic, strong, readonly) UpdatesManager* updateManager;
@property (nonatomic) BOOL backgroundModeActive;
@property (nonatomic, copy) void(^onUpdateCoordinatesBlock)();

@property (assign) NSInteger totalDownloadBytes;
@property (assign) NSInteger totalUploadBytes;

@property(nonatomic, strong, readonly) Settings* settings;

+ (Model*) sharedInstance;
- (void) clear;

- (BOOL) isLoggedOn;
- (void) login:(NSDictionary*)user session:(NSString*)session success:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (void) loginWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (void) resetPasswordWithEmail:(NSString*)email onSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (void) trackUser:(DBUser*)user fromDate:(NSDate*)from toDate:(NSDate*)to withSuccess:(void(^)(NSArray* pins))onSuccess onError:(void(^)(NSString* error))onError;

- (void) searchGroupsWithCountryID:(NSInteger)countryID cityID:(NSInteger)cityID withSuccess:(void(^)(NSArray* groups))onSuccess onError:(void(^)(NSString* error))onError;
- (void) loadUsers:(DBGroup*)group withSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError;
- (void) logout;
- (void) searchAddresses:(CLLocationCoordinate2D)coordinates withSuccess:(void(^)(NSArray* results))onSuccess onError:(void(^)(NSString* error))onError;

@end
