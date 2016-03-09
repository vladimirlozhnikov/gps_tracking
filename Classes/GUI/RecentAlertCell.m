//
//  RecentAlertCell.m
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "RecentAlertCell.h"

@implementation RecentAlertCell

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
	self.textField.enabled = selected;

	if (selected)
    {
        [self.textField becomeFirstResponder];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
	[textField resignFirstResponder];
	[self.delegate recentAlertCell:self didChangeText:textField.text];
}

@end
