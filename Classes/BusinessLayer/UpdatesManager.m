//
//  UpdatesManager.m
//  GPSTracker
//
//  Created by YS on 3/17/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UpdatesManager.h"
#import "Model.h"
#import "UpdateInfo.h"
#import "TypeUtils.h"
#import "Settings.h"
#import "DBGroup+Methods.h"

@interface UpdatesManager()
{
	NSUInteger _pendedUpdatesCount;
}

@property (nonatomic) NSTimer* pingTimer;
@property (nonatomic) UpdateInfo* updateInfo;
@property (atomic) NSUInteger pendedUpdatesCount;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) BOOL isUpdatePingActive;
@property (nonatomic) BOOL previousValue;
@property (nonatomic) BOOL isVersionAlertDisplayed;

#ifndef NDEBUG
@property (nonatomic) BOOL usersUpdateActive;
@property (nonatomic) BOOL messagesActive;
@property (nonatomic) BOOL updatePinsActive;

#endif

@end

@implementation UpdatesManager

- (void) setPendedUpdatesCount:(NSUInteger)pendedUpdatesCount
{
	@synchronized(self)
	{
		_pendedUpdatesCount = pendedUpdatesCount;

		if(pendedUpdatesCount == 0)
        {
            //NSLog(@"pended updates queue is BLANK");
        }
	}
}

- (NSUInteger) pendedUpdatesCount
{
	@synchronized (self)
	{
		return _pendedUpdatesCount;
	}
}

- (void) dealloc
{
	[self.pingTimer invalidate];
	self.pingTimer = nil;
}

- (void) pingIsActive:(BOOL)active frequency:(RequestsFrequency)frequency
{
	if (active)
	{
		self.updatePinsActive = NO;//DEBUG
		self.usersUpdateActive = NO;//DEBUG
		self.messagesActive = NO;//DEBUG
		
		if (!self.pingTimer)
		{
			NSInteger timeout = [[Model sharedInstance].settings timeoutForRequestsFrequency];
			if (timeout == -1)
			{
				[self.pingTimer invalidate];
				self.pingTimer = nil;
				return;
			}
			
			self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onUpdatePing:) userInfo:nil repeats:YES];
		}
	}
	else
	{
		[self.pingTimer invalidate];
		self.pingTimer = nil;
	}
    
	self.isUpdatePingActive = active;
}

- (void) handleMessagesUpdate
{
	if ([Model sharedInstance].myMessages.isUpdateInProgress)
	{
		--self.pendedUpdatesCount;
		self.messagesActive = NO;//DEBUG
        
		return;
	}

	[[Model sharedInstance].myMessages updateMessageListWithLimit:self.updateInfo.messagesCount success:^(NSArray *messages)
	{
		if([messages count] && self.updateBlock)
        {
            self.updateBlock(UpdateTypeMessages, nil, nil);
        }
		
		if (self.backgroundModeActive)
		{
			UILocalNotification* notification = [UILocalNotification new];
			notification.applicationIconBadgeNumber = [messages count];
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
        
		--self.pendedUpdatesCount;
		self.messagesActive = NO;//DEBUG
	}
	onError:^(NSString *error)
	{
		NSLog(@"cannot update messages");
		--self.pendedUpdatesCount;
        
		self.messagesActive = NO;//DEBUG
	}];
}

- (void) handleUsersUpdate
{
	NSMutableArray* joinedUsers = [NSMutableArray array];
	NSArray* leftUsers = nil;
	if ([self.updateInfo.joinedUsers count])
	{
		for (NSDictionary* joinedUser in self.updateInfo.joinedUsers)
        {
            [joinedUsers addObject:[DBUser userWithDictionary:joinedUser]];
        }
		
		[self.activeGroup addUsersWithArray:joinedUsers];
	}
	if ([self.updateInfo.leftUsers count])
	{
		leftUsers = [self.activeGroup removeUsersWithArray:self.updateInfo.leftUsers];
	}
	
	if(self.updateBlock)
    {
        self.updateBlock(UpdateTypeUsers, leftUsers, joinedUsers);
    }

	--self.pendedUpdatesCount;
	self.usersUpdateActive = NO;//DEBUG
}

- (void) handleUpdates
{
	self.pendedUpdatesCount = 1;
	self.updatePinsActive = YES;//DEBUG
	
	if (self.updateInfo.messagesCount)
	{
		++self.pendedUpdatesCount;
		self.messagesActive = YES;//DEBUG
	}
	if ([self.updateInfo.joinedUsers count] || [self.updateInfo.leftUsers count])
	{
		++self.pendedUpdatesCount;
		self.usersUpdateActive = YES;//DEBUG
	}
		
	if (self.updateInfo.messagesCount)
    {
        [self handleMessagesUpdate];
    }
	if ([self.updateInfo.joinedUsers count] || [self.updateInfo.leftUsers count])
    {
        [self handleUsersUpdate];
    }
	
	if (self.activeGroup)
	{
		[self.activeGroup updatePinsForUsersWithSuccess:^
		 {
			 if (self.updateBlock)
			 {
				 self.updateBlock(UpdateTypePins, nil, nil);
			 }
             
			 --self.pendedUpdatesCount;
			 self.updatePinsActive = NO;//DEBUG
		 }];
	}
	else
	{
		--self.pendedUpdatesCount;
		self.updatePinsActive = NO;//DEBUG		
	}

    float currentVesrion = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
    float serverVersion = [self.updateInfo.version floatValue];
    
	if (!self.isVersionAlertDisplayed && (serverVersion > currentVesrion))
	{
		self.isVersionAlertDisplayed = YES;
        NSString* alertText = [NSString stringWithFormat:@"The newest version (%@) is available", self.updateInfo.version];
		if (self.backgroundModeActive)
		{
			UILocalNotification* notification = [UILocalNotification new];
			notification.alertBody = alertText;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
		}
		else
		{
			[DELEGATE showAlertWithMessage:alertText];
		}
	}
}

- (void) immediateUpdatePing
{
	[self onUpdatePing:nil];
}

- (void) onUpdatePing:(NSTimer*)timer
{
	//@synchronized(self)
	{
		if (self.pendedUpdatesCount > 0)
		{
/*			NSLog(@"UPDATE pended because of running other updates:");
			if(self.updatePinsActive)//DEBUG
				NSLog(@"pins ACTIVE");

			if(self.usersUpdateActive)//DEBUG
				NSLog(@"users ACTIVE");

			if(self.messagesActive)//DEBUG
				NSLog(@"message ACTIVE");
			
			NSLog(@""); */
			return;
		}
		
		if (self.isBusy)
			return;
		
        //NSLog(@"send ping");
		self.isBusy = YES;
		[[Model sharedInstance].httpClient getPath:@"ping" parameters:nil
		success:^(AFHTTPRequestOperation *operation, id responseObject)
		{
			NSDictionary* result = responseObject;
            //NSLog(@"response: %@", result);
            
            NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
            [Model sharedInstance].totalDownloadBytes = [data2 length];
            
			if (![[result objectForKey:@"success"] boolValue])
			{
				//NSLog(@"%@", [[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
                
				return;
			}
            
			self.updateInfo = [UpdateInfo updateInfoWithDictionary:result];
			[self handleUpdates];

			self.isBusy = NO;
		}
		failure:^(AFHTTPRequestOperation *operation, NSError *error)
		{
            NSLog(@"failure, onUpdatePing, response: %@", [operation responseString]);
            [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
			self.isBusy = NO;
		}];
	}
}

- (void) setBackgroundModeActive:(BOOL)backgroundModeActive
{
	if (_backgroundModeActive == backgroundModeActive)
		return;
	
	_backgroundModeActive = backgroundModeActive;
    
	if (_backgroundModeActive)
	{
		self.previousValue = self.isUpdatePingActive;
		[self pingIsActive:NO frequency:[Model sharedInstance].settings.requestsFrequency];
	}
	else
	{
		[self pingIsActive:self.previousValue frequency:[Model sharedInstance].settings.requestsFrequency];
	}
}

@end
