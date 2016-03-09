//
//  Pin.m
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Pin.h"
#import "DateUtils.h"

@interface Pin()

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString* userID;
@property (nonatomic) NSString* date;
@property (nonatomic) NSDate* dateTime;

@end

@implementation Pin

+ (Pin*) pinWithCoordinate:(CLLocationCoordinate2D)coordinate userID:(NSString*)userID
{
	Pin* pin = [Pin new];
    
	pin.coordinate = coordinate;
	pin.userID = userID;
	pin.dateTime = [NSDate date];
    
	return pin;
}

- (NSDictionary*) dictionaryPresentation
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSDictionary* pin = [NSDictionary dictionaryWithObjectsAndKeys:dictionary, @"pin", nil];
    
	[dictionary setObject:@(self.coordinate.latitude) forKey:@"latitude"];
	[dictionary setObject:@(self.coordinate.longitude) forKey:@"longitude"];
	[dictionary setObject:self.userID forKey:@"user_id"];
	[dictionary setObject:self.date forKey:@"time"];
    
	return pin;
}

+ (Pin*) pinWithDictionary:(NSDictionary*)dictionary
{
	Pin* pin = [Pin new];
    
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = [[dictionary objectForKey:@"latitude"] doubleValue];
	coordinate.longitude = [[dictionary objectForKey:@"longitude"] doubleValue];
	pin.coordinate = coordinate;
	pin.dateTime = [DateUtils dateFromUnixString:[dictionary objectForKey:@"time"]];
	pin.userID = [dictionary objectForKey:@"user_id"];
    
	return pin;
}

- (NSString*) date
{
	return [DateUtils stringFromDate:self.dateTime];
}

@end
