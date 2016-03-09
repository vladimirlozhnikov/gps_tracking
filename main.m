//
//  main.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
	@autoreleasepool
	{
		@try
        {
			return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
		}
		@catch (NSException *exception)
		{
            [[[GAI sharedInstance] defaultTracker] sendException:YES withNSException:exception];
            
			NSLog(@"@catch (NSException *exception): %@", [exception callStackSymbols]);
            NSLog(@"reason: %@", [exception reason]);
		}
	}
}
