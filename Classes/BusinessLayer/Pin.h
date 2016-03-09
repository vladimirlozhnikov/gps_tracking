//
//  Pin.h
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Pin : NSObject

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, weak, readonly) NSString* userID;
@property (nonatomic, weak, readonly) NSString* date;

+ (Pin*) pinWithCoordinate:(CLLocationCoordinate2D)coordinate userID:(NSString*)userID;
- (NSDictionary*) dictionaryPresentation;
+ (Pin*) pinWithDictionary:(NSDictionary*)dictionary;

@end
