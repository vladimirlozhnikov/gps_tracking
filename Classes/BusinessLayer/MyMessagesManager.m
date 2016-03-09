//
//  MyMessagesManager.m
//  GPSTracker
//
//  Created by YS on 3/17/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyMessagesManager.h"
#import "Model.h"
#import "FileUtils.h"
#import "DBMessage+Methods.h"

@interface MyMessagesManager()

@property(nonatomic) BOOL isUpdateInProgress;

@end

@implementation MyMessagesManager

- (id) init
{
	if (self = [super init])
	{
	}
    
	return self;
}

- (NSArray*) parseMessages:(NSArray*)messages
{
	NSMutableArray* results = [NSMutableArray array];
	for (NSDictionary* info in messages)
	{
		DBMessage* msg = [DBMessage messageWithDictionary:info];
		[results addObject:msg];
	}
    
	return results;
}

- (void) updateMessageListWithLimit:(NSUInteger)limit success:(void(^)(NSArray* messages))onSuccess onError:(void(^)(NSString* error))onError
{
	self.isUpdateInProgress = YES;
	NSString* path = [NSString stringWithFormat:@"messages"];
	NSDictionary* params = @{@"limit": @(limit)};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:path parameters:params
	success:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		NSDictionary* result = responseObject;
        
        NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
        [Model sharedInstance].totalDownloadBytes = [data2 length];
        
		if (![[result objectForKey:@"success"] boolValue])
		{
			onError([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
            
			return;
		}
        
		NSArray* newMessages = [self parseMessages:[result objectForKey:@"messages"]];
        [DELEGATE.me addMessagesWithArray:newMessages];
		
        NSInteger unreadCount = [[self unreadMessages] count];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
        
		onSuccess(newMessages);
		self.isUpdateInProgress = NO;
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, updateMessageListWithLimit, response: %@", [operation responseString]);
		onError([error localizedDescription]);
		self.isUpdateInProgress = NO;
	}];
}

- (void) clear
{
	[DELEGATE.me removeMessages:DELEGATE.me.messages];
}

- (NSArray*) unreadMessages
{
    NSArray* unreadMessages = [[DELEGATE.me.messages filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isUnread == YES"]] allObjects];
    
	return unreadMessages;
}

@end
