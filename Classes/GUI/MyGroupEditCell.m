//
//  MyGroupEditCell.m
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyGroupEditCell.h"

@implementation MyGroupEditCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
		UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 132, 60)];
        [self addSubview:view];
		
		[view addSubview:self.buttonLeft];
		[view addSubview:self.buttonRight];
	}
    
	return self;
}

- (IBAction) onRight
{
	[self.delegate cell:self isLeft:NO];
}

- (IBAction) onLeft
{
	[self.delegate cell:self isLeft:YES];
}

@end
