//
//  DBColor+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBColor+Methods.h"

@implementation DBColor (Methods)

+ (UIColor*) colorWithHexString:(NSString*)hex
{
	NSScanner* scanner = [NSScanner scannerWithString:hex];
	unsigned int baseColor;
	[scanner scanHexInt:&baseColor];
	
	int red = ((baseColor >> 16) & 0xFF) / 255.f;
    int green = ((baseColor >> 8) & 0xFF) / 255.f;
    int blue = ((baseColor) & 0xFF) / 255.f;
	
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
}

+ (NSString*) hexStringWithColor:(UIColor*)color
{
	const CGFloat* components = CGColorGetComponents([color CGColor]);
	int intComponents[3] = {components[0] * 255, components[1] * 255, components[2] * 255};
    
	return [NSString stringWithFormat:@"%02x%02x%02x", intComponents[0], intComponents[1], intComponents[2]];
}

@end
