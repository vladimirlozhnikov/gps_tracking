//
//  FontTextField.m
//  GPSTracker
//
//  Created by YS on 1/31/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "FontTextField.h"

@implementation FontTextField

-(id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.font = [UIFont fontWithName:@"PlainScriptCTT" size:self.font.pointSize];
	}
	return self;
}

- (void) drawPlaceholderInRect:(CGRect)rect
{
	[[UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font];
}

@end
