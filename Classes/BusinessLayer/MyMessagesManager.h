//
//  MyMessagesManager.h
//  GPSTracker
//
//  Created by YS on 3/17/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyMessagesManager : NSObject

- (void) updateMessageListWithLimit:(NSUInteger)limit success:(void(^)(NSArray* messages))onSuccess onError:(void(^)(NSString* error))onError;
- (NSArray*) unreadMessages;
- (void) clear;

@property(nonatomic, readonly) BOOL isUpdateInProgress;

@end
