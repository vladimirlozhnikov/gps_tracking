//
//  DateUtils.h
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+(NSString*)stringFromDate:(NSDate*)date;
+(NSDate*)dateFromString:(NSString*)dateString;
+(NSDate*)dateFromUnixString:(NSString*)dateString;
+(NSString*)UnixStringFromDate:(NSDate*)date;

@end
