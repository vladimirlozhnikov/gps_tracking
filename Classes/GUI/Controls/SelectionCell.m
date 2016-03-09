//
//  SelectionCell.m
//  GPSTracker
//
//  Created by YS on 1/28/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SelectionCell.h"

@implementation SelectionCell

- (void)updateSelection
{
	UIColor* color = nil;
	if(self.selected)
		color = [UIColor colorWithRed:62.f/255 green:60.f/255 blue:57.f/255 alpha:1.f];
	else
		color = [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
	
	self.label.textColor = color;
	self.imageTick.hidden = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	[self updateSelection];
}

@end
