//
//  Model.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Model.h"
#import "FileUtils.h"
#import "Settings.h"
#import "DBMessage+Methods.h"
#import "DBCountry+Methods.h"
#import "TypeUtils.h"
#import "AppDelegate.h"
#import "PPDbManager.h"
#import "DBGroup+Methods.h"
#import "Pin.h"

@interface Model()

@property(nonatomic) NSDate* lastTimestamp;
@property(nonatomic) NSTimeInterval timeLast;

@end

@implementation Model

@synthesize settings = _settings;
@synthesize httpClient = _httpClient;
@synthesize errorTranslator = _errorTranslator;
@synthesize locations = _locations;
@synthesize myGroups = _myGroups;
@synthesize myMessages = _myMessages;
@synthesize updateManager = _updateManager;

typedef void(^OnSuccess)(void);
typedef void(^OnError)(NSString* error);
typedef void(^OnSuccessSearch)(NSArray* groups);
typedef void(^OnSuccessUsersSearch)(NSArray* users);

Model* _sharedModel = nil;

- (AFHTTPClient*) httpClient
{
	return _httpClient;
}

+ (Model*) sharedInstance
{
	if (!_sharedModel)
    {
        _sharedModel = [Model new];
    }
	
	return _sharedModel;
}

- (void) clear
{
    [_myGroups clear];
    [_locations clear];
    
    _myGroups = nil;
    _updateManager = nil;
    DELEGATE.me = nil;
    DELEGATE.me.onUpdateCoordinatesBlock = nil;
}

- (id) init
{
	if (self = [super init])
	{
		_errorTranslator = [ErrorTranslator new];
		_credentials = [Credentials new];
		_settings = [Settings new];
		_locations = [Locations new];
		
		NSString* baseURL = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerBaseURL"];
		_httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
		[_httpClient setDefaultHeader:@"X-Developerkey" value:@"9a23ed390b8598bcfb3c0f66b66fc08363661d81"];
		[_httpClient setDefaultHeader:@"Accept" value:@"text/json"];
//		[_httpClient setDefaultHeader:@"X-Debug" value:@"1"];
		[_httpClient setParameterEncoding:AFJSONParameterEncoding];
        [_httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
	}
    
	return self;
}

- (NSArray*) parseGroups:(NSArray*)groups
{
	NSMutableArray* result = [NSMutableArray array];
	for (NSDictionary* groupInfo in groups)
    {
        DBGroup* g = [DBGroup groupWithDictionary:groupInfo];
        [result addObject:g];
    }
	
	return result;
}

- (void) loadUsers:(DBGroup*)group withSuccess:(OnSuccess)onSuccess onError:(OnError)onError
{
    [DELEGATE showActivity];
    [group updateUsersWithCriteria:@"" withSuccess:^{
        [DELEGATE hideActivity];
        onSuccess();
    } onError:^(NSString *error) {
        [DELEGATE hideActivity];
        onError(error);
    }];
}

- (void) loadGroupsUsers:(NSArray*)groups withSuccess:(OnSuccessSearch)onSuccess onError:(OnError)onError
{
	OnSuccessSearch successBlock = onSuccess;
	OnError errorBlock = onError;

	__block NSUInteger groupsCount = [groups count];
    if (groupsCount > 0)
    {
        for (DBGroup* group in groups)
        {
			[group updateUsersWithCriteria:@"" withSuccess:^
			{
				--groupsCount;
				if(!groupsCount)
                {
                    successBlock(groups);
                }
			}
			onError:^(NSString *error)
			{
				errorBlock(error);
			}];			
        }
    }
    else
    {
        successBlock(groups);
    }
}

- (void) searchGroupsWithCountryID:(NSInteger)countryID cityID:(NSInteger)cityID withSuccess:(void(^)(NSArray* groups))onSuccess onError:(void(^)(NSString* error))onError
{
    NSMutableString* criteria = [NSMutableString string];
    if (countryID > 0)
    {
        [criteria appendFormat:@"country_id=%d", countryID];
    }
    if (cityID > 0)
    {
        [criteria appendFormat:@"|city_id=%d", cityID];
    }
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:criteria, @"criteria", nil];
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
    [self.myGroups clear];
    
	[_httpClient postPath:@"groups/search" parameters:params
	success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSDictionary* result = responseObject;
        
        NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        [Model sharedInstance].totalDownloadBytes = [data2 length];
        
		if (![[result objectForKey:@"success"] boolValue])
		{
			onError([self.errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
			return;
		}
        
        NSDictionary* totalGroups = [result objectForKey:@"groups"];
        NSArray* groups = [self parseGroups:[totalGroups objectForKey:@"withCriteria"]];
        
        for (DBGroup* group in [self parseGroups:[totalGroups objectForKey:@"myself"]])
		{
			[self.myGroups addGroup:group];
		}
        
        onSuccess(groups);
		//[self loadGroupsUsers:groups withSuccess:onSuccess onError:onError];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, searchGroupsWithCountryID, response: %@", [operation responseString]);
		onError([error localizedDescription]);
	}];
}

- (BOOL) isLoggedOn
{
	return _bLogged;
}

- (void) updateMessagesWithSuccessBlock:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
	[self.myMessages updateMessageListWithLimit:100 success:^(NSArray *messages)
	{
		onSuccess();
	}
	onError:^(NSString *error)
	{
		onError(error);
	}];
}

- (void) updateCountriesWithSuccessBlock:(void(^)(void))onSuccessBlock onError:(void(^)(NSString* error))onError
{
	[self.locations countriesWithSuccess:^(NSArray* objects)
	{
		if (self.locations.locationCountry)
        {
            self.settings.lastCountryID = [self.locations.locationCountry.index integerValue];
        }
		 
		if(self.locations.locationCity)
        {
            self.settings.lastCityID = [self.locations.locationCity.index integerValue];
        }
		 
		onSuccessBlock();
	}
	onError:^(NSString *error)
	{
		onError(error);
	}];
}

- (void) logout
{
	[_httpClient.operationQueue cancelAllOperations];
	_bLogged = NO;
    DELEGATE.me = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:self];
	_locations = nil;
	_myGroups = nil;
	_updateManager = nil;
}

- (void) searchAddresses:(CLLocationCoordinate2D)coordinates withSuccess:(void(^)(NSArray* results))onSuccess onError:(void(^)(NSString* error))onError
{
    NSString* baseURL = @"https://maps.googleapis.com";
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    [httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f,%f", coordinates.latitude, coordinates.longitude], @"location", [NSNumber numberWithInt:200], @"radius", @"true", @"sensor", @"AIzaSyBoo19UocgR_Z7uTBSKoRse45BhNvXJm_E", @"key", nil];
    
    [httpClient getPath:@"maps/api/place/search/json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* result = responseObject;
        NSArray* places = [result objectForKey:@"results"];
        onSuccess(places);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        onError([error localizedDescription]);
    }];
}

- (void) login:(NSDictionary*)user session:(NSString*)session success:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
    _bLogged = YES;
    
    _myGroups = [MyGroupsManager new];
    _myMessages = [MyMessagesManager new];
    _updateManager = [UpdatesManager new];
    
    DELEGATE.me = [DBUser userWithDictionary:user];
    
    //!!!__block typeof(self) bSelf = self;
    DELEGATE.me.onUpdateCoordinatesBlock = ^()
    {
        /*!!!if(bSelf.settings.requestsFrequency == RequestsFrequencyAutomatically)
         {
         [bSelf.updateManager immediateUpdatePing];
         }
         
         if([bSelf.settings timeoutInBackground] != -1 && bSelf.lastTimestamp && bSelf.backgroundModeActive && bSelf.isLoggedOn)
         {
         NSDate* currentDate = [NSDate date];
         bSelf.timeLast += [currentDate timeIntervalSinceDate:bSelf.lastTimestamp];
         bSelf.lastTimestamp = currentDate;
         
         if (bSelf.timeLast >= [bSelf.settings timeoutInBackground])
         {
         bSelf.lastTimestamp = nil;
         bSelf.timeLast = 0;
         
         [bSelf.updateManager.activeGroup leaveWithSuccess:^
         {
         [bSelf logout];
         }
         onError:^(NSString *error)
         {
         [bSelf logout];
         }];
         }
         }*/
    };
    
    [_httpClient setDefaultHeader:@"X-Session" value:session];
    
    [self updateCountriesWithSuccessBlock:^
     {
         [self.locations determineLocationCountry];
         
         if (self.locations.locationCountry)
         {
             [self.locations citiesByCountry:self.locations.locationCountry onSuccess:^(NSArray* objects)
              {
                  [self.locations determineLocationCity];
                  [self updateMessagesWithSuccessBlock:onSuccess onError:onError];
              } onError:^(NSString *error)
              {
                  [self updateMessagesWithSuccessBlock:onSuccess onError:onError];
              }];
         }
         else
         {
             [self updateMessagesWithSuccessBlock:onSuccess onError:onError];
         }
     } onError:^(NSString *error)
     {
         onError(error);
     }];
}

- (void) loginWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	[params setObject:self.credentials.username forKey:@"email"];
	[params setObject:self.credentials.password forKey:@"password"];
	[params setObject:[NSNumber numberWithInteger:[Model sharedInstance].settings.language] forKey:@"language"];
	[params setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"version"];
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
	
	[_httpClient postPath:@"users/login" parameters:params
	success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSDictionary* result = responseObject;
        
        NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        [Model sharedInstance].totalDownloadBytes = [data2 length];
        
		if(![[result objectForKey:@"success"] boolValue])
		{
			onError([self.errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
            
			return;
		}
        NSString* session = [result objectForKey:@"session"];
        NSDictionary* user = [result objectForKey:@"user"];
        
        [self login:user session:session success:^{
            onSuccess();
        } onError:^(NSString *error) {
            onError(error);
        }];
        
		/*_bLogged = YES;
        
		_myGroups = [MyGroupsManager new];
		_myMessages = [MyMessagesManager new];
		_updateManager = [UpdatesManager new];
        
		DELEGATE.me = [DBUser userWithDictionary:[result objectForKey:@"user"]];
        
		//!!!__block typeof(self) bSelf = self;
		DELEGATE.me.onUpdateCoordinatesBlock = ^()
		{
		};
		
		[_httpClient setDefaultHeader:@"X-Session" value:[result objectForKey:@"session"]];
				
		[self updateCountriesWithSuccessBlock:^
		{
			[self.locations determineLocationCountry];
			
			if (self.locations.locationCountry)
			{
				[self.locations citiesByCountry:self.locations.locationCountry onSuccess:^(NSArray* objects)
				{
					[self.locations determineLocationCity];
					[self updateMessagesWithSuccessBlock:onSuccess onError:onError];
				}
				onError:^(NSString *error)
				{
					[self updateMessagesWithSuccessBlock:onSuccess onError:onError];
				}];
			}
			else
			{
				[self updateMessagesWithSuccessBlock:onSuccess onError:onError];
			}
		}
		onError:^(NSString *error)
		{
			onError(error);
		}];*/
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, loginWithSuccess, response: %@", [operation responseString]);
		onError([error localizedDescription]);
	}];
}

- (void) resetPasswordWithEmail:(NSString*)email onSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
	__block OnSuccess successBlock = onSuccess;
	__block OnError errorBlock = onError;
    
    NSDictionary* params = @{@"email": email};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[_httpClient postPath:@"users/forgot_password" parameters:@{@"email": email}
	success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSDictionary* result = responseObject;
        
        NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        [Model sharedInstance].totalDownloadBytes = [data2 length];
        
		if (![[result objectForKey:@"success"] boolValue])
		{
			errorBlock([self.errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
			return;
		}
        
		successBlock();
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, resetPasswordWithEmail, response: %@", [operation responseString]);
		errorBlock([error localizedDescription]);
	}];
}

- (void) trackUser:(DBUser*)user fromDate:(NSDate*)from toDate:(NSDate*)to withSuccess:(void(^)(NSArray* pins))onSuccess onError:(void(^)(NSString* error))onError
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:user.index, @"user_id", [NSNumber numberWithDouble:(NSUInteger)[to timeIntervalSince1970]], @"to", [NSNumber numberWithDouble:(NSUInteger)[from timeIntervalSince1970]], @"from", nil];
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[_httpClient postPath:@"track" parameters:params
                  success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             onError([self.errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         NSMutableArray* pins = [NSMutableArray array];
         for (NSDictionary* p in [result objectForKey:@"gps"])
         {
             Pin* pin = [Pin pinWithDictionary:p];
             [pins addObject:pin];
         }
         onSuccess(pins);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, trackUser, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (void) setBackgroundModeActive:(BOOL)backgroundModeActive
{
	if (!self.isLoggedOn)
		return;
	
	if (_backgroundModeActive == backgroundModeActive)
		return;
	
	if (backgroundModeActive && (self.settings.timeoutInBackground != -1))
	{
		self.timeLast = 0;
		self.lastTimestamp = [NSDate date];
	}
	else
	{
		self.timeLast = 0;
		self.lastTimestamp = nil;
	}
	
	_backgroundModeActive = backgroundModeActive;
	self.settings.backgroundModeActive = backgroundModeActive;
	DELEGATE.me.backgroundModeActive = backgroundModeActive;
	self.updateManager.backgroundModeActive = backgroundModeActive;
}

#pragma mark - Properties

- (NSInteger) totalDownloadBytes
{
    return self.settings.totalDownloadBytes;
}

- (void) setTotalDownloadBytes:(NSInteger)theTotalDownloadBytes
{
    NSInteger total = self.settings.totalDownloadBytes;
    total += theTotalDownloadBytes;
    
    self.settings.totalDownloadBytes = total;
    [self.settings save];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app trafficChanged:[self.settings friendlyDownloadTraffic] friendlyUpload:[self.settings friendlyUploadTraffic]];
}

- (NSInteger) totalUploadBytes
{
    return self.settings.totalUploadBytes;
}

- (void) setTotalUploadBytes:(NSInteger)theTotalUploadBytes
{
    NSInteger total = self.settings.totalUploadBytes;
    total += theTotalUploadBytes;
    
    self.settings.totalUploadBytes = total;
    [self.settings save];
    
    AppDelegate* app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app trafficChanged:[self.settings friendlyDownloadTraffic] friendlyUpload:[self.settings friendlyUploadTraffic]];
}

@end
