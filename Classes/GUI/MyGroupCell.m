//
//  MyGroupCell.m
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyGroupCell.h"

@implementation MyGroupCell

- (void) setSelected:(BOOL)selected
{
	[super setSelected:selected];

	UIColor* color = nil;
	if(self.selected)
    {
        color = [UIColor colorWithRed:62.f/255 green:60.f/255 blue:57.f/255 alpha:1.f];
    }
	else
    {
        color = [UIColor colorWithRed:135.f/255 green:132.f/255 blue:127.f/255 alpha:1.f];
    }
	
	self.labelText.textColor = color;
	self.buttonTickbox.selected = self.selected;
}

@end
