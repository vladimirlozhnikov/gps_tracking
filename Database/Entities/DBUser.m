//
//  DBUser.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 07.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBUser.h"
#import "DBGroup.h"
#import "DBMessage.h"


@implementation DBUser

@dynamic email;
@dynamic firstName;
@dynamic imageAvatar;
@dynamic imageUrl;
@dynamic index;
@dynamic lastName;
@dynamic nickName;
@dynamic phoneNumber;
@dynamic messages;
@dynamic myGroups;
@synthesize delegate;

@end
