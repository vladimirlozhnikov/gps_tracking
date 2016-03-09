
//
//  Color.m
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Color.h"

@implementation Color

- (id) init
{
	if (self = [super init])
	{
		NSUInteger color = rand() % 3;
		switch (color)
		{
			case 0:
				self.red = 1.f;
				break;
			case 1:
				self.green = 1.f;
				break;
			case 2:
				self.blue = 1.f;
				break;
			default:
				break;
		}
	}
    
	return self;
}

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
