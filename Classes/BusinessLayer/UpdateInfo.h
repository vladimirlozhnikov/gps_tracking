//
//  UpdateInfo.h
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateInfo : NSObject

@property (nonatomic, readonly) NSUInteger messagesCount;
@property (nonatomic, weak, readonly) NSString* version;
@property (nonatomic, weak, readonly) NSArray* joinedUsers;
@property (nonatomic, weak, readonly) NSArray* leftUsers;

+ (UpdateInfo*) updateInfoWithDictionary:(NSDictionary*)dictionary;

@end
