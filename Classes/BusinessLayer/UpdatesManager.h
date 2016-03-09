//
//  UpdatesManager.h
//  GPSTracker
//
//  Created by YS on 3/17/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Types.h"

@class DBGroup;

typedef void(^UpdateBlock)(UpdateType, NSArray* leftUsers, NSArray* joinedUsers);

@interface UpdatesManager : NSObject

@property (nonatomic, copy) UpdateBlock updateBlock;
@property (nonatomic, weak) DBGroup* activeGroup;
@property (nonatomic) BOOL backgroundModeActive;

- (void) pingIsActive:(BOOL)active frequency:(RequestsFrequency)frequency;
- (void) immediateUpdatePing;

@end
