//
//  Bundle_DE.m
//  GPSTracker
//
//  Created by YS on 2/3/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BundleEx.h"
#import "Model.h"

@implementation BundleEx

- (NSString* )pathForResource:(NSString *)name ofType:(NSString *)ext
{
	NSString* base = nil;
	NSString* str = nil;
    
	if ([ext isEqualToString:@"png"])
	{
		base = [[NSBundle mainBundle] bundlePath];
		str = [[NSString alloc] initWithFormat:@"%@/%@.%@", base, name, ext];
	}
	else
    {
        str = [super pathForResource:name ofType:ext];
    }
	
	return str;
}

@end
