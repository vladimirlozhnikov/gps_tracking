//
//  DBColor+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBColor.h"

@interface DBColor (Methods)

+ (UIColor*) colorWithHexString:(NSString*)hex;
+ (NSString*) hexStringWithColor:(UIColor*)color;

@end
