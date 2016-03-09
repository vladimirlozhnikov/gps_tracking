//
//  UserMapMenuVC.m
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UserMapMenuVC.h"
#import "DBUser+Methods.h"

@implementation UserMapMenuVC

- (void) viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
}

- (IBAction) onCall
{
    if ([self.user.index isEqualToString:DELEGATE.me.index])
    {
        return;
    }
    
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.user.phoneNumber]]];
}

- (IBAction) onStats
{
    [self.delegate performSelector:@selector(statisticsDidChoose)];
}

- (IBAction)onDetailsMessage
{
    if ([self.user.index isEqualToString:DELEGATE.me.index])
    {
        //return;
    }
    
	[self.delegate userMapMenuVCOnDetailsMessage:self];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    
     self.buttonPhoneNumber.enabled = ([self.user.phoneNumber length] == 0) ? NO : YES;
}

- (void) viewDidUnload
{
	[self setButtonStats:nil];
	[self setButtonPhoneNumber:nil];
	[super viewDidUnload];
}

@end
