//
//  SearchGroupCell.m
//  GPSTracker
//
//  Created by YS on 1/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SearchGroupCell.h"

@implementation SearchGroupCell
@synthesize index;

- (IBAction) onOwner
{
	[self.delegate searchGroupCellOnOwner:self];
}

- (IBAction) onUsers
{
	[self.delegate searchGroupCellOnUsers:self];
}

- (IBAction) onLogin
{
    [self.delegate searchGroupCellOnLogin:self];
}

@end
