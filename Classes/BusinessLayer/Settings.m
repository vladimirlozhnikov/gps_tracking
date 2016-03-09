//
//  Settings.m
//  GPSTracker
//
//  Created by YS on 2/6/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "Settings.h"
#import "FileUtils.h"
#import "BundleEx.h"
#import <objc/runtime.h>

@interface Settings()

@property(nonatomic) BOOL previousValue;
@property(nonatomic) NSDictionary* frequencies;

- (NSString*) getPath;

@end

@implementation Settings

- (void) createLanguageMap
{
	_languageMap = @{@0 : @"automatic", @1 : @"be", @2 : @"de", @3 : @"en", @4 : @"es", @5 : @"fr", @6 : @"ru", @7 : @"zh-Hans", @8 : @"pl", @9 : @"it", @10 : @"tr"};
}

- (Language) autoDetectLanguage
{
	NSString* code = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
	
	for (NSNumber* key in [_languageMap allKeys])
	{
		NSString* value = [_languageMap objectForKey:key];
		if([value isEqualToString:@"zh-Hans"] && [value rangeOfString:code].location != NSNotFound)
        {
            return [key intValue];
        }
		else if([value isEqualToString:code])
        {
            return [key intValue];
        }
	}
    
	return LanguageEnglish;
}

- (id) init
{
	if (self = [super init])
	{
        NSString* path = [self getPath];
        if (path != nil)
        {
            content = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        }
        
		[self createLanguageMap];
		
		self.frequencies = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerRequestFrequency"];
		
		[self setCurrentLanguage:self.language];
	}
	return self;
}

- (void) dealloc
{
	[self save];
}

- (NSString*) getPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documents = [paths objectAtIndex:0];
    NSString* str = [NSString stringWithFormat:@"%@.%@", @"Settings", @"plist"];
    NSString* alerts = [[NSString alloc] initWithString:[documents stringByAppendingPathComponent:str]];
    
    return alerts;
}

- (void) save
{
    NSString* path = [self getPath];
    if (path != nil)
    {
        [content writeToFile:path atomically:NO];
    }
}

- (void) setLanguage:(Language)language
{
	[self setCurrentLanguage:language];
}

- (void) setCurrentLanguage:(Language)language
{
	Language languageForBundle = language;
	
	if(language == LanguageAutomatic)
    {
        languageForBundle = [self autoDetectLanguage];
    }
	
	NSString* name = [_languageMap objectForKey:[NSNumber numberWithInt:languageForBundle]];
	NSString* fullname = [FileUtils resourcePath:[NSString stringWithFormat:@"%@.bundle", name]];
	_bundle = [NSBundle bundleWithPath:fullname];
	object_setClass(_bundle, [BundleEx class]);
    
    [content setValue:[NSNumber numberWithInteger:language] forKey:@"language"];
}

- (Language) language
{
    return [[content valueForKey:@"language"] integerValue];
}

- (BOOL) agpsIsOn
{
    return [[content valueForKey:@"agps"] boolValue];
}

- (void) setAgpsIsOn:(BOOL)agpsIsOn
{
    [content setValue:[NSNumber numberWithBool:agpsIsOn] forKey:@"agps"];
}

- (NSBundle*) bundle
{
	return _bundle;
}

- (NSInteger) timeoutForRequestsFrequency
{
	if(self.requestsFrequency == RequestsFrequencyAutomatically)
		return -1;
	
	return [[self.frequencies objectForKey:[NSString stringWithFormat:@"%d", self.requestsFrequency]] intValue];
}

- (NSInteger) timeoutInBackground
{
	switch (self.activeInBackground)
	{
		case ActiveInBackgroundAlways:
			return -1;
			break;
		case ActiveInBackground30:
			return 30 * 60;
			break;
		case ActiveInBackgroundHour:
			return 60 * 60;
			break;
		case ActiveInBackground3Hours:
			return 60 * 60 * 3;
			break;
		case ActiveInBackground12Hours:
			return 60 * 60 * 12;
			break;
		default:
			break;
	}
}

- (void) setBackgroundModeActive:(BOOL)backgroundModeActive
{
	if (_backgroundModeActive == backgroundModeActive)
		return;
	
	_backgroundModeActive = backgroundModeActive;
    
	if (backgroundModeActive)
	{
		self.previousValue = self.requestsFrequency;
		self.requestsFrequency = RequestsFrequencyAutomatically;
	}
	else
	{
		self.requestsFrequency = self.previousValue;
	}
}

#pragma mark - Properties

- (NSInteger) lastCountryID
{
    NSInteger countryId = [[content valueForKey:@"lastCountryID"] integerValue];
    return countryId > 0 ? countryId : -1;
}

- (void) setLastCountryID:(NSInteger)lastCountryID
{
    if (lastCountryID > 0)
    {
        [content setValue:[NSNumber numberWithInteger:lastCountryID] forKey:@"lastCountryID"];
    }
}

- (NSInteger) lastCityID
{
    NSInteger citiId = [[content valueForKey:@"lastCityID"] integerValue];
    return citiId > 0 ? citiId : -1;
}

- (void) setLastCityID:(NSInteger)lastCityID
{
    if (lastCityID)
    {
        [content setValue:[NSNumber numberWithInteger:lastCityID] forKey:@"lastCityID"];
    }
}

- (ActiveInBackground) activeInBackground
{
    return [[content valueForKey:@"activeInBackground"] integerValue];
}

- (void) setActiveInBackground:(ActiveInBackground)activeInBackground
{
    [content setValue:[NSNumber numberWithInteger:activeInBackground] forKey:@"activeInBackground"];
}

- (RequestsFrequency) requestsFrequency
{
    return [[content valueForKey:@"requestsFrequency"] integerValue];
}

- (void) setRequestsFrequency:(RequestsFrequency)requestsFrequency
{
    [content setValue:[NSNumber numberWithInteger:requestsFrequency] forKey:@"requestsFrequency"];
}

- (NSMutableArray*) alertTemplates
{
    return [content valueForKey:@"alertTemplates"];
}

- (void) setAlertTemplates:(NSMutableArray *)alertTemplates
{
    [content setValue:alertTemplates forKey:@"alertTemplates"];
}

- (NSInteger) totalDownloadBytes
{
    return [[content valueForKey:@"totalDownloadBytes"] integerValue];
}

- (void) setTotalDownloadBytes:(NSInteger)totalDownloadBytes
{
    [content setValue:[NSNumber numberWithInteger:totalDownloadBytes] forKey:@"totalDownloadBytes"];
}

- (NSInteger) totalUploadBytes
{
    return [[content valueForKey:@"totalUploadBytes"] integerValue];
}

- (void) setTotalUploadBytes:(NSInteger)totalUploadBytes
{
    [content setValue:[NSNumber numberWithInteger:totalUploadBytes] forKey:@"totalUploadBytes"];
}

- (NSString*) friendlyUploadTraffic
{
    float f = 0;
    float upload = self.totalUploadBytes;
    
    if (upload < (10 * 1024))
    {
        return [NSString stringWithFormat:@"%0.0f B(s)", upload];
    }
    else if (upload < (700 * 1024))
    {
        f = upload / 1024;
        return [NSString stringWithFormat:@"%0.2f Kb(s)", f];
    }
    
    f = upload / 1024 / 1024;
    return [NSString stringWithFormat:@"%0.2f Mb(s)", f];
}

- (NSString*) friendlyDownloadTraffic
{
    float f = 0;
    float download = self.totalDownloadBytes;
    
    if (download < (10 * 1024))
    {
        return [NSString stringWithFormat:@"%.0f B(s)", download];
    }
    else if (download < (2000 * 1024))
    {
        f = download / 1024;
        return [NSString stringWithFormat:@"%0.2f Kb(s)", f];
    }
    
    f = download / (1024 * 1000);
    
    return [NSString stringWithFormat:@"%0.2f Mb(s)", f];
}

@end
