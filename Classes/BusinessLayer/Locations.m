//
//  Countries.m
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Locations.h"
#import "Model.h"
#import "PPDbManager.h"

@interface Locations()

@property (atomic, weak) NSString* locationCountryString;
@property (atomic, weak) NSString* locationCityString;
@property (nonatomic, weak) DBCountry* locationCountry;
@property (nonatomic, weak) DBCity* locationCity;

@end

@implementation Locations
@synthesize countries = _countries;

typedef void(^OnSuccess)(NSArray* objects);
typedef void(^OnError)(NSString* error);

- (void) determineLocationCountry
{
	if (!self.locationCountryString)
    {
        return;
    }
	
	for (DBCountry* country in self.countries)
	{
		if ([country.name rangeOfString:self.locationCountryString].location != NSNotFound)
		{
			self.locationCountry = country;
			self.locationCity = nil;
            
			break;
		}
	}
}

- (void) determineLocationCity
{
	if (!self.locationCityString)
    {
        return;
    }
	
	NSArray* cities = [_cities objectForKey:self.locationCountry.index];
	if (!cities)
    {
        return;
    }
	
	for (DBCity* city in cities)
	{
		if ([city.name rangeOfString:self.locationCityString].location != NSNotFound)
		{
			self.locationCity = city;
            
			break;
		}
	}
}

- (void) clear
{
    [_countries removeAllObjects];
    [_cities removeAllObjects];
}

- (void) determineLocationInfo
{
    NSInteger countryId = [Model sharedInstance].settings.lastCountryID;
    NSInteger cityId = [Model sharedInstance].settings.lastCityID;
    self.locationCountry = nil;
	self.locationCity = nil;
	
    for (DBCountry* country in self.countries)
    {
        if ([country.index integerValue] == countryId)
        {
            self.locationCountry = country;
            break;
        }
    }
    
    NSArray* cities = [_cities objectForKey:[NSString stringWithFormat:@"%d", countryId]];
	for (DBCity* city in cities)
	{
        if ([city.index integerValue] == cityId)
        {
            self.locationCity = city;
			break;
        }
	}
    
    if (!self.locationCountry && !self.locationCity)
    {
        [self determineLocationCountry];
        [self determineLocationCity];
    }
}

- (id) init
{
	if (self = [super init])
	{
		_countries = [NSMutableArray array];
		_cities = [NSMutableDictionary dictionary];
		[self userCountryWithSuccessResult:^(NSString *error)
         {
             if(error)
             {
                 return;
             }
             
             [self determineLocationInfo];
         }];
	}
    
	return self;
}

- (void) countriesWithSuccess:(void(^)(NSArray* objects))onSuccess onError:(void(^)(NSString* error))onError
{
    [_countries removeAllObjects];
    [_cities removeAllObjects];
	
	[[Model sharedInstance].httpClient getPath:@"countries" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             onError([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             
             return;
         }
         
         for (NSDictionary* countryInfo in [result objectForKey:@"countries"])
         {
             DBCountry* country = [DBCountry countryWithDictionary:countryInfo];
             [_countries addObject:country];
         }
         
         [self determineLocationInfo];
         onSuccess(_countries);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, countriesWithSuccess, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (void) citiesByCountry:(DBCountry*)country onSuccess:(void(^)(NSArray* objects))onSuccess onError:(void(^)(NSString* error))onError
{
    [_cities removeAllObjects];
	
	__block NSString* path = [NSString stringWithFormat:@"countries/%@/cities", country.index];
	[[Model sharedInstance].httpClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             onError([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             
             return;
         }
         
         NSMutableArray* cities = [NSMutableArray array];
         for (NSDictionary* cityInfo in [result objectForKey:@"cities"])
         {
             [cities addObject:[DBCity cityWithDictionary:cityInfo]];
         }
         
         DBCity* allCities = [PPDbManager objectForEntityName:@"DBCity"];
         allCities.index = @"-2";
         allCities.name = @"...";
         
         [cities insertObject:allCities atIndex:0];
         [_cities setObject:cities forKey:country.index];
         [self determineLocationInfo];
         
         onSuccess(cities);
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, citiesByCountry, response: %@", [operation responseString]);
         onError([error localizedDescription]);
     }];
}

- (DBCountry*) countryByCountryID:(NSUInteger)countryID
{
	for (DBCountry* country in self.countries)
	{
		if ([country.index integerValue] == countryID)
        {
            return country;
        }
	}
    
	return nil;
}

- (void) userCountryWithSuccessResult:(void(^)(NSString* error))onResult
{
	userCountryResult = onResult;
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.distanceFilter = 50;
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    
    if ([locations count] > 0)
    {
        CLLocation* newLocation = [locations lastObject];
        DELEGATE.me.coordinate = newLocation.coordinate;
        [DELEGATE.me onUpdatePin:nil];
    }
    
    locationManager.delegate = nil;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [locationManager stopUpdatingLocation];
    DELEGATE.me.coordinate = newLocation.coordinate;
    [DELEGATE.me onUpdatePin:nil];
    
	/*CLGeocoder* geocoder = [CLGeocoder new];
	[geocoder reverseGeocodeLocation:manager.location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (![placemarks count])
         {
             userCountryResult(@"No info");
             return;
         }
         
         CLPlacemark* placemark = [placemarks lastObject];
         self.locationCountryString = placemark.country;
         self.locationCityString = placemark.locality;
         
         [DELEGATE.locationManager stopUpdatingLocation];
         DELEGATE.locationManager.delegate = nil;
         
         userCountryResult(nil);
     }];*/
    locationManager.delegate = nil;
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //!!! [DELEGATE.locationManager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    
	userCountryResult([error localizedDescription]);
}

- (NSInteger) indexByCountryID:(NSUInteger)countryID
{
	for (NSUInteger i = 0; i < [self.countries count]; ++i)
	{
		DBCountry* country = [self.countries objectAtIndex:i];
		if([country.index integerValue] == countryID)
        {
            return i;
        }
	}
    
	//NSAssert(NO, @"Country not found");
	return -1;
}

- (NSInteger) indexByCityID:(NSUInteger)cityID forCountryID:(NSUInteger)countryID
{
	NSArray* cities = [_cities objectForKey:[NSString stringWithFormat:@"%d", countryID]];
	for (NSUInteger i = 0; i < [cities count]; ++i)
	{
		DBCity* city = [cities objectAtIndex:i];
		if ([city.index integerValue] == cityID)
        {
            return i;
        }
	}
    
	//NSAssert(NO, @"City not found");
	return -1;
}

- (DBCity*) cityByCityID:(NSUInteger)cityID forCountryID:(NSUInteger)countryID
{
	NSArray* cities = [_cities objectForKey:[NSString stringWithFormat:@"%d", countryID]];
	for (NSUInteger i = 0; i < [cities count]; ++i)
	{
		DBCity* city = [cities objectAtIndex:i];
		if ([city.index integerValue] == cityID)
        {
            return city;
        }
	}
    
	//NSAssert(NO, @"City not found");
	return nil;
}

@end
