//
//  ErrorTranslator.m
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "ErrorTranslator.h"
#import "FileUtils.h"

@implementation ErrorTranslator

- (id) init
{
	if (self = [super init])
	{
		_errors = [NSDictionary dictionaryWithContentsOfFile:[FileUtils resourcePath:@"Errors.plist"]];
	}
    
	return self;
}

- (NSString*) descriptionForError:(NSUInteger)error
{
	NSString* description = [_errors objectForKey:[NSString stringWithFormat:@"%d", error]];
	if (description)
    {
        NSString* localizedText = [DELEGATE localizedStringForKey:@"Authorization error"];
        return localizedText;
    }
		
	return @"Unknown error";
}

@end
