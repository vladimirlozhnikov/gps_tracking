//
//  GrayedStrikeoutButton.m
//  GPSTracker
//
//  Created by YS on 2/1/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "GrayedStrikeoutButton.h"

@implementation GrayedStrikeoutButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		UIColor* color = [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
		[self setTitleColor:color forState:UIControlStateNormal];
		[self setTitleColor:color forState:UIControlStateHighlighted];
	}
	return self;
}

@end
