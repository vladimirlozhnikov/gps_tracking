//
//  UITableViewEx.m
//  GPSTracker
//
//  Created by YS on 1/9/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UITableViewEx.h"

@implementation UITableViewEx

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	NSIndexPath* indexPath = [self indexPathForRowAtPoint:[touch locationInView:self]];
    
	if (!indexPath && ![touch.view isKindOfClass:[UITextField class]])
	{
		NSIndexPath* selectedIndexPath = [self indexPathForSelectedRow];
        if (selectedIndexPath)
        {
            [self.delegate tableView:self didDeselectRowAtIndexPath:selectedIndexPath];
            [self endEditing:YES];
        }
	}
	else
	{
		[super touchesBegan:touches withEvent:event];
	}
}

@end
