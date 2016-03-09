//
//  DBMessage.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 07.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBAttachment, DBUser;

@interface DBMessage : NSManagedObject

@property (nonatomic, strong) NSNumber * date;
@property (nonatomic, strong) NSNumber * flag;
@property (nonatomic, strong) NSString * index;
@property (nonatomic, strong) NSNumber * isUnread;
@property (nonatomic, strong) NSNumber * priority;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) DBAttachment *attachment;
@property (nonatomic, strong) DBUser *from;

@end
