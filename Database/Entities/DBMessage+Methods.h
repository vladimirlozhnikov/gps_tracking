//
//  DBMessage+Methods.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBMessage.h"

typedef enum
{
	MessagePriorityNormal = 0,
	MessagePriorityHigh,
	MessagePriorityOther
}MessagePriority;

@class DBUser;

@interface DBMessage (Methods)

@property (readonly, nonatomic, weak) NSDate* friendlyDate;

+ (DBMessage*) messageWithText:(NSString*)text image:(UIImage*)image priority:(MessagePriority)priority user:(DBUser*)user;
+ (DBMessage*) messageWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) dictionaryPresentation;

- (NSComparisonResult) sortByDate:(DBMessage*)otherMessage;

@end
