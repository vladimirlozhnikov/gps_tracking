//
//  GrayedLabel.m
//  GPSTracker
//
//  Created by YS on 2/1/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "GrayedLabel.h"

@implementation GrayedLabel

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.textColor = [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
	}
	return self;
}

@end
