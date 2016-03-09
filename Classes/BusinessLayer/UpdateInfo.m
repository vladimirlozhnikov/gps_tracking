//
//  UpdateInfo.m
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UpdateInfo.h"

@interface UpdateInfo()

@property (nonatomic) NSUInteger messagesCount;
@property (nonatomic) NSString* version;
@property (nonatomic) NSArray* joinedUsers;
@property (nonatomic) NSArray* leftUsers;

@end

@implementation UpdateInfo

+ (UpdateInfo*) updateInfoWithDictionary:(NSDictionary*)dictionary
{
	UpdateInfo* info = [UpdateInfo new];
    
	info.messagesCount = [[dictionary objectForKey:@"message_quantity"] intValue];
	info.version = [dictionary objectForKey:@"version"];
	info.leftUsers = [dictionary objectForKey:@"left_users"];
	info.joinedUsers = [dictionary objectForKey:@"joined_users"];
    
	return info;
}

@end
