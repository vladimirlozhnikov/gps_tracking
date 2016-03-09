//
//  FontLabel.m
//  GPSTracker
//
//  Created by YS on 1/31/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "FontLabel.h"

@implementation FontLabel

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.font = [UIFont fontWithName:@"PlainScriptCTT" size:self.font.pointSize];
	}
	return self;
}

@end
