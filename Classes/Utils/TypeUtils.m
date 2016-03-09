//
//  TypeUtils.m
//  GPSTracker
//
//  Created by YS on 3/9/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TypeUtils.h"

@implementation TypeUtils

+(NSString*)radiusString:(Radius)radius
{
	switch (radius)
	{
		case Radius1:
			return @"1";
			break;
		case Radius1_5:
			return @"1-5";
			break;
		case Radius5_15:
			return @"5-15";
			break;
		case Radius15_70:
			return @"15-70";
			break;
		default:
			break;
	}
	return nil;
}

@end
