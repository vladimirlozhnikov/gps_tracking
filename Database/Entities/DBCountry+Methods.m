//
//  DBCountry+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBCountry+Methods.h"
#import "PPDbManager.h"

@implementation DBCountry (Methods)

+ (DBCountry*) countryWithDictionary:(NSDictionary*)dictionary
{
	DBCountry* country = [PPDbManager itemForEntitiNameAndCriteria:@"DBCountry" withCriteria:[NSString stringWithFormat:@"index LIKE '%@'", [dictionary objectForKey:@"country_id"]]];
    
    if (!country)
    {
        country = [PPDbManager objectForEntityName:@"DBCountry"];
    }
    
	country.index = [dictionary objectForKey:@"country_id"];
	country.name = [dictionary objectForKey:@"name"];
    
	return country;
}

- (NSDictionary*) dictionaryPresentation
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:self.index forKey:@"country_id"];
	[dictionary setObject:self.name forKey:@"name"];
	return dictionary;
}

@end
