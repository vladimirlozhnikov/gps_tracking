//
//  Countries.h
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBCity+Methods.h"
#import "DBCountry+Methods.h"
#import <CoreLocation/CoreLocation.h>

@interface Locations : NSObject<CLLocationManagerDelegate>
{
	void(^userCountryResult)(NSString* error);
	NSMutableArray* _countries;
	NSMutableDictionary* _cities;
    CLLocationManager* locationManager;
}

@property (nonatomic, strong, readonly) NSMutableArray* countries;
@property (nonatomic, weak, readonly) DBCountry* locationCountry;
@property (nonatomic, weak, readonly) DBCity* locationCity;

- (void) countriesWithSuccess:(void(^)(NSArray* objects))onSuccess onError:(void(^)(NSString* error))onError;
- (void) citiesByCountry:(DBCountry*)country onSuccess:(void(^)(NSArray* objects))onSuccess onError:(void(^)(NSString* error))onError;
- (DBCountry*) countryByCountryID:(NSUInteger)countryID;
- (void) userCountryWithSuccessResult:(void(^)(NSString* error))onResult;
- (NSInteger) indexByCountryID:(NSUInteger)countryID;
- (NSInteger) indexByCityID:(NSUInteger)cityID forCountryID:(NSUInteger)countryID;
- (DBCity*) cityByCityID:(NSUInteger)cityID forCountryID:(NSUInteger)countryID;
- (void) determineLocationCountry;
- (void) determineLocationCity;
- (void) clear;

@end
