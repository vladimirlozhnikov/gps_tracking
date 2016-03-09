//
//  MyGroupsManager.h
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBGroup;

@interface MyGroupsManager : NSObject
{
}

- (void) removeGroupAtIndex:(NSUInteger)index;
- (NSUInteger) count;
- (DBGroup*) groupAtIndex:(NSUInteger)index;
- (void) exchangePositionFrom:(NSUInteger)from to:(NSUInteger)to;
- (void)addGroup:(DBGroup*)group;

- (void) clear;

- (void) createGroup:(DBGroup*)group withContacts:(NSArray*)users onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;
- (void) deleteGroup:(DBGroup*)group withSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError;

@end
