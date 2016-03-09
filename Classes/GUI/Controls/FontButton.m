//
//  FontButton.m
//  GPSTracker
//
//  Created by YS on 1/31/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "FontButton.h"

@implementation FontButton

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.titleLabel.font = [UIFont fontWithName:@"PlainScriptCTT"
											   size:self.titleLabel.font.pointSize];
		self.titleLabel.minimumFontSize = 9.f;
		self.titleLabel.adjustsFontSizeToFitWidth = YES;
	}
	return self;
}

@end
