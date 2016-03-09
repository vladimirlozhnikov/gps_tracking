//
//  Credentials.m
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Credentials.h"

@implementation Credentials

- (id) init
{
	if (self = [super init])
	{
		[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"isRemember": @YES}];
		[self load];
	}
    
	return self;
}

- (BOOL) isFilled
{
	return [self.username length] && [self.password length];
}

- (void) load
{
	self.isRemember = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRemember"];
	self.username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
	if(self.isRemember)
    {
        self.password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    }
}

- (void) save
{
	[[NSUserDefaults standardUserDefaults] setObject:self.username forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] setBool:self.isRemember forKey:@"isRemember"];

	if(self.isRemember)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.password forKey:@"password"];
    }

	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
