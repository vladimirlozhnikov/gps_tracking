//
//  MyGroupsManager.m
//  GPSTracker
//
//  Created by YS on 3/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyGroupsManager.h"
#import "FileUtils.h"
#import "DBGroup+Methods.h"
#import "Model.h"
#import "PPDbManager.h"

@implementation MyGroupsManager

typedef void(^OnSuccessSimple)();
typedef void(^OnError)(NSString* error);

- (id) init
{
	if (self = [super init])
	{
	}
    
	return self;
}

- (void) addGroup:(DBGroup*)group
{
    BOOL exists = NO;
    for (DBGroup* g in [DELEGATE.me.myGroups allObjects])
    {
        if ([g.ind isEqualToString:group.ind])
        {
            exists = YES;
            break;
        }
    }
    
    if (!exists)
    {
        [DELEGATE.me addMyGroupsObject:group];
    }
}

- (void) removeGroup:(DBGroup*)group
{
    [DELEGATE.me removeMyGroupsObject:group];
}

- (void) removeGroupAtIndex:(NSUInteger)index
{
    NSArray* groups = [DELEGATE.me.myGroups allObjects];
    for (DBGroup* group in groups)
    {
        NSUInteger i = [groups indexOfObject:group];
        if (i == index)
        {
            [DELEGATE.me removeMyGroupsObject:group];
            return;
        }
    }
}

- (void) exchangePositionFrom:(NSUInteger)from to:(NSUInteger)to
{
    NSMutableArray* mutableArray = [NSMutableArray array];
    NSSet* set = [NSSet setWithArray:mutableArray];
    
    NSArray* groups = [DELEGATE.me.myGroups allObjects];
    DBGroup* fromGroup = [groups objectAtIndex:from];
    DBGroup* toGroup = [groups objectAtIndex:to];
    
    for (DBGroup* group in groups)
    {
        if ([group isEqual:fromGroup])
        {
            [mutableArray addObject:toGroup];
        }
        else if ([group isEqual:toGroup])
        {
            [mutableArray addObject:fromGroup];
        }
        else
        {
            [mutableArray addObject:group];
        }
    }
    
    [DELEGATE.me removeMyGroups:DELEGATE.me.myGroups];
    [DELEGATE.me addMyGroups:set];
}

- (NSUInteger) count
{
    return [DELEGATE.me.myGroups count];
}

- (DBGroup*) groupAtIndex:(NSUInteger)index
{
	NSArray* groups = [DELEGATE.me.myGroups allObjects];
    return [groups objectAtIndex:index];
}

- (void) clear
{
    [DELEGATE.me removeMyGroups:DELEGATE.me.myGroups];
}

- (void) createGroup:(DBGroup*)group withContacts:(NSArray*)users onSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
	NSDictionary* params = @{@"group": [group dictionaryPresentation], @"email" : users};
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:@"groups/create" parameters:params
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
        
		group.ind = [result objectForKey:@"groupid"];
		[self addGroup:group];
        
		onSuccess();
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, createGroup, response: %@", [operation responseString]);
		onError([error localizedDescription]);
	}];
}

- (void) deleteGroup:(DBGroup*)group withSuccess:(void(^)())onSuccess onError:(void(^)(NSString* error))onError
{
	NSString* path = [NSString stringWithFormat:@"groups/delete/%@", [group ind]];
	[[Model sharedInstance].httpClient postPath:path parameters:nil
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
        
		[self removeGroup:group];
		onSuccess();
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
        [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
        NSLog(@"failure, deleteGroup, response: %@", [operation responseString]);
		onError([error localizedDescription]);
	}];
}

@end
