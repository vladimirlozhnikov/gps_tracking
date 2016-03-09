//
//  DBCity+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBCity+Methods.h"
#import "PPDbManager.h"

@implementation DBCity (Methods)

+ (DBCity*) cityWithDictionary:(NSDictionary*)dictionary
{
	DBCity* city = [PPDbManager itemForEntitiNameAndCriteria:@"DBCity" withCriteria:[NSString stringWithFormat:@"index LIKE '%@'", [dictionary objectForKey:@"city_id"]]];
    
    if (!city)
    {
        city = [PPDbManager objectForEntityName:@"DBCity"];
    }
    
    if ([[dictionary objectForKey:@"city_id"] integerValue] != -1)
    {
        city.index = [dictionary objectForKey:@"city_id"];
    }
	city.name = [dictionary objectForKey:@"name"];
    
	return city;
}

- (NSDictionary*) dictionaryPresentation
{
	return @{@"city_id" : [self.index length] > 0 ? self.index : @"", @"name" : self.name};
}

@end
