//
//  DBCity+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBCity.h"

@interface DBCity (Methods)

+ (DBCity*) cityWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) dictionaryPresentation;

@end
