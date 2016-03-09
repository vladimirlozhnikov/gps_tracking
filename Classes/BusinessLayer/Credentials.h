//
//  Credentials.h
//  GPSTracker
//
//  Created by YS on 2/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Credentials : NSObject

@property (nonatomic, weak) NSString* username;
@property (nonatomic, weak) NSString* password;
@property (nonatomic) BOOL isRemember;

- (BOOL) isFilled;
- (void) save;

@end
