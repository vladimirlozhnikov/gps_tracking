//
//  DBCountry+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBCountry.h"

@interface DBCountry (Methods)

+ (DBCountry*) countryWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) dictionaryPresentation;

@end
