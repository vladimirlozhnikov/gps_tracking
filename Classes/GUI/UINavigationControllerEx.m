//
//  UINavigationControllerEx.m
//  GPSTracker
//
//  Created by YS on 1/9/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UINavigationControllerEx.h"

@implementation UINavigationControllerEx

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	BaseVC* vc = (BaseVC*)[self topViewController];
	[vc pushAnimation:^()
	{
		[super pushViewController:viewController animated:NO];
	}];
}

- (UIViewController*) popViewControllerAnimated:(BOOL)animated
{
	__block UIViewController* poppedVC = nil;
	BaseVC* vc = (BaseVC*)[self topViewController];
	[vc popAnimation:^()
	 {
		 poppedVC = [super popViewControllerAnimated:NO];
	 }];
    
	return poppedVC;
}

@end
