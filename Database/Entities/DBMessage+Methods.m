//
//  DBMessage+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBMessage+Methods.h"
#import "PPDbManager.h"
#import "Base64.h"
#import "DBAttachment.h"
#import "DBUser+Methods.h"
#import "DateUtils.h"
#import "DBAttachment+Methods.h"
#import "ImageUtils.h"

@implementation DBMessage (Methods)

#pragma mark - Properties

- (NSDate*) friendlyDate
{
    return [NSDate dateWithTimeIntervalSince1970:[self.date doubleValue]];
}

#pragma mark Methods

+ (DBMessage*) messageWithText:(NSString*)text image:(UIImage*)image priority:(MessagePriority)priority user:(DBUser*)user
{
    //NSLog(@"messageWithText");
    DBMessage* message = [PPDbManager objectForEntityName:@"DBMessage"];
    if (image)
    {
        DBAttachment* attachment = [PPDbManager objectForEntityName:@"DBAttachment"];
        UIImage* lowImage = [ImageUtils imageWithLowQuality:image];
        attachment.image = UIImageJPEGRepresentation(lowImage, 0);
        message.attachment = attachment;
    }
    
    message.from = user;
	message.text = text;
	message.priority = [NSNumber numberWithInteger:priority];
    
	return message;
}

+ (DBMessage*) messageWithDictionary:(NSDictionary*)dictionary
{
    DBMessage* message = [PPDbManager itemForEntitiNameAndCriteria:@"DBMessage" withCriteria:[NSString stringWithFormat:@"index LIKE '%@'", [dictionary objectForKey:@"id"]]];
    
    if (!message)
    {
        message = [PPDbManager objectForEntityName:@"DBMessage"];
        message.attachment = [DBAttachment attachmentWithDictionary:[dictionary objectForKey:@"attachment"]];
        message.isUnread = [NSNumber numberWithBool:YES];
    }
    
    message.index = [dictionary objectForKey:@"id"];
    message.text = [dictionary objectForKey:@"text"];
    message.priority = [NSNumber numberWithInteger:[[dictionary objectForKey:@"flag"] intValue]];
    message.from = [DBUser userWithDictionary:[dictionary objectForKey:@"from"]];
    message.date = [NSNumber numberWithDouble:[[DateUtils dateFromUnixString:[dictionary objectForKey:@"time"]] timeIntervalSince1970]];
    
    //NSString* isUnread = [dictionary objectForKey:@"isUnread"];
    //message.isUnread = [NSNumber numberWithBool:[isUnread boolValue]];
    
	return message;
}

- (NSDictionary*) dictionaryPresentation
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
	[dictionary setObject:[self.index length] > 0 ? self.index : @"" forKey:@"id"];
	[dictionary setObject:self.text forKey:@"text"];
	[dictionary setObject:self.attachment ? [self.attachment attachmentToDictionary] : @"" forKey:@"attachment"];
	[dictionary setObject:self.priority forKey:@"flag"];
	[dictionary setObject:[self.from dictionaryPresentation] forKey:@"from"];
	//[dictionary setObject:self.isUnread ? self.isUnread : @"" forKey:@"isUnread"];
	
	if(self.date)
    {
        [dictionary setObject:[DateUtils UnixStringFromDate:self.friendlyDate] forKey:@"time"];
    }
	else
    {
        [dictionary setObject:@"" forKey:@"time"];
    }
	
	return dictionary;
}

- (void) encodeWithCoder:(NSCoder*)aCoder
{
	[aCoder encodeObject:[self dictionaryPresentation]];
}

- (NSComparisonResult) sortByDate:(DBMessage*)otherMessage
{
    return [self.date doubleValue] < [otherMessage.date doubleValue];
}

@end
