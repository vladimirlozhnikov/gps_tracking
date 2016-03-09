//
//  DateUtils.m
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

NSDateFormatter *messageDateFormatter = nil;

+(NSString*)stringFromDate:(NSDate*)date
{
	if(!messageDateFormatter)
	{
		messageDateFormatter = [NSDateFormatter new];
		[messageDateFormatter setDateFormat:@"dd.MM.yy hh:mm"];
	}
	return [messageDateFormatter stringFromDate:date];
}

+(NSDate*)dateFromUnixString:(NSString*)dateString
{
	return [NSDate dateWithTimeIntervalSince1970:[dateString doubleValue]];
}

+(NSString*)UnixStringFromDate:(NSDate*)date
{
	return [NSString stringWithFormat:@"%d", (NSUInteger)[date timeIntervalSince1970]];
}

+(NSDate*)dateFromString:(NSString*)dateString
{
	if(!messageDateFormatter)
	{
		messageDateFormatter = [NSDateFormatter new];
		[messageDateFormatter setDateFormat:@"dd.MM.yy"];
	}
	return [messageDateFormatter dateFromString:dateString];
}

@end
