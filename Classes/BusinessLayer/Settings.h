//
//  Settings.h
//  GPSTracker
//
//  Created by YS on 2/6/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@class BundleEx;

@interface Settings : NSObject
{
	NSDictionary* _languageMap;
	NSBundle* _bundle;
    BOOL rememberMe;
    
    NSMutableDictionary* content;
}

@property (nonatomic) NSInteger lastCountryID;
@property (nonatomic) NSInteger lastCityID;

@property (nonatomic) Language language;
@property (nonatomic) ActiveInBackground activeInBackground;
@property (nonatomic) RequestsFrequency requestsFrequency;
@property (nonatomic) BOOL agpsIsOn;

@property (nonatomic, weak, readonly) NSBundle* bundle;
@property (nonatomic, weak) NSMutableArray* alertTemplates;
@property (nonatomic) BOOL backgroundModeActive;

@property (assign) NSInteger totalUploadBytes;
@property (assign) NSInteger totalDownloadBytes;

- (void) save;
- (NSInteger) timeoutForRequestsFrequency;
- (NSInteger) timeoutInBackground;

- (NSString*) friendlyUploadTraffic;
- (NSString*) friendlyDownloadTraffic;

@end
