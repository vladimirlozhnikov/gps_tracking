//
//  DBUser+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "DBUser+Methods.h"
#import "PPDbManager.h"
#import "ImageUtils.h"
#import "Model.h"
#import "Pin.h"
#import "Base64.h"
#import "DBMessage+Methods.h"
#import "UIImage+Methods.h"

@implementation DBUser (Methods)
@dynamic previousValue;
@dynamic isBusy;
@dynamic isUpdatePinActive;
@dynamic coordinate;
@dynamic pinTimer;
@dynamic updateInfo;
@dynamic backgroundModeActive;

typedef void (^OnSuccessArray)(NSArray* array);
typedef void (^OnSuccess)(NSDictionary* response);
typedef void (^OnSuccess1)(void);
typedef void (^OnError)(NSString* error);

-(void) dealloc
{
	[self.pinTimer invalidate];
	self.pinTimer = nil;
}

+ (DBUser*) userWithDictionary:(NSDictionary*)dictionary
{
    DBUser* user = [PPDbManager itemForEntitiNameAndCriteria:@"DBUser" withCriteria:[NSString stringWithFormat:@"index LIKE '%@'", [dictionary objectForKey:@"userid"]]];
    if (!user)
    {
        user = [PPDbManager objectForEntityName:@"DBUser"];
    }
    
	user.nickName = [dictionary objectForKey:@"nickname"];
	user.phoneNumber = [dictionary objectForKey:@"phonenumber"];
	user.index = [dictionary objectForKey:@"userid"];
	
	NSString* avatar = [dictionary objectForKey:@"avatar"];
	if (avatar != (NSString*)[NSNull null])
    {
        if (([avatar length] > 0) && ![user.imageUrl isEqualToString:avatar])
        {
            user.imageAvatar = nil;
        }
        
        user.imageUrl = avatar;
    }
    
	user.email = [dictionary objectForKey:@"email"];
	user.lastName = [dictionary objectForKey:@"surname"];
	user.firstName = [dictionary objectForKey:@"username"];
	user.status	= [[dictionary objectForKey:@"status"] intValue];
    
	return user;
}

+(DBUser*) userWithFirstName:(NSString*)firstName lastName:(NSString*)lastName email:(NSString*)email
{
    DBUser* user = [PPDbManager itemForEntitiNameAndCriteria:@"DBUser" withCriteria:[NSString stringWithFormat:@"email LIKE '%@'", email]];
    if (!user)
    {
        user = [PPDbManager objectForEntityName:@"DBUser"];
    }
    
	user.firstName = firstName;
	user.lastName = lastName;
	user.email = email;
    
	return user;
}

- (NSDictionary*) dictionaryPresentation
{
	NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary* userDictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:userDictionary forKey:@"user"];
    
	[userDictionary setObject:[self.nickName length] > 0 ? self.nickName : @"" forKey:@"nickname"];
	[userDictionary setObject:self.phoneNumber ? self.phoneNumber : @"" forKey:@"phonenumber"];
	[userDictionary setObject:[self.index length] > 0 ? self.index : @"" forKey:@"userid"];
	
	/*if (self.imageAvatar)
    {
        [userDictionary setObject:[Base64 encode:self.imageAvatar] forKey:@"avatar"];
    }
	else*/
    {
        [userDictionary setObject:@"" forKey:@"avatar"];
    }
	
	[userDictionary setObject:[self.email length] > 0 ? self.email : @"" forKey:@"email"];
	[userDictionary setObject:[self.lastName length] > 0 ? self.lastName : @"" forKey:@"surname"];
	[userDictionary setObject:@(self.status) forKey:@"status"];
	[userDictionary setObject:[self.firstName length] > 0 ? self.firstName : @"" forKey:@"username"];
    
	return dictionary;
}

- (void) addMessagesWithArray:(NSArray*)messages
{
    for (DBMessage* m in messages)
	{
        BOOL exists = NO;
        for (DBMessage* m1 in [self.messages allObjects])
        {
            if ([m1.index isEqualToString:m.index])
            {
                exists = YES;
                break;
            }
        }
        
        if (!exists)
        {
            m.isUnread = [NSNumber numberWithBool:YES];
            [self addMessagesObject:m];
        }
	}
}

- (void) registerWithSuccess:(void(^)(NSDictionary* response))onSuccess onError:(void(^)(NSString* error))onError saveAvatar:(BOOL)saveAvatar
{
	__block OnSuccess successBlock = onSuccess;
	__block OnError errorBlock = onError;
	
	NSDictionary* params = [self dictionaryPresentation];
    
    if (saveAvatar)
    {
        if ([self.imageAvatar length] > 0)
        {
            NSMutableDictionary* userDictionary = [params objectForKey:@"user"];
            [userDictionary setObject:[Base64 encode:self.imageAvatar] forKey:@"avatar"];
        }
    }
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
    
	[[Model sharedInstance].httpClient postPath:@"users/register" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         //NSLog(@"%@", result);
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if(![[result objectForKey:@"success"] boolValue])
         {
             errorBlock([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         NSString* error = [result objectForKey:@"error"];
         if ([error integerValue] == 14)
         {
             successBlock(result);
         }
         else
         {
             [Model sharedInstance].credentials.username = self.email;
             [Model sharedInstance].credentials.password = [result objectForKey:@"password"];
             [[Model sharedInstance].credentials save];
             
              successBlock(result);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, registerWithSuccess, response: %@", [operation responseString]);
         errorBlock([error localizedDescription]);
     }];
}

-(void) updateWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
	__block OnSuccess1 successBlock = onSuccess;
	__block OnError errorBlock = onError;
	
	NSString* path = @"users/update";
    NSMutableDictionary* params = (NSMutableDictionary*)[self dictionaryPresentation];
    
    if ([self.imageAvatar length] > 0)
    {
        NSMutableDictionary* userDictionary = (NSMutableDictionary*)[params objectForKey:@"user"];
        [userDictionary setObject:[Base64 encode:self.imageAvatar] forKey:@"avatar"];
    }
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];

	[[Model sharedInstance].httpClient postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         NSLog(@"%@", result);
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if(![[result objectForKey:@"success"] boolValue])
         {
             errorBlock([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         successBlock();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, updateWithSuccess, response: %@", [operation responseString]);
         errorBlock([error localizedDescription]);
     }];
}

-(void) abuseWithSuccess:(void(^)(void))onSuccess onError:(void(^)(NSString* error))onError
{
	__block OnSuccess1 successBlock = onSuccess;
	__block OnError errorBlock = onError;
	
	NSString* path = [NSString stringWithFormat:@"complain/%@", self.index];
	[[Model sharedInstance].httpClient getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if(![[result objectForKey:@"success"] boolValue])
         {
             errorBlock([[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         successBlock();
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         NSLog(@"failure, abuseWithSuccess, response: %@", [operation responseString]);
         errorBlock([error localizedDescription]);
     }];
}

-(void) onUpdatePin:(NSTimer*)timer
{
    //NSLog(@"onUpdatePin");
	if(!CLLocationCoordinate2DIsValid(self.coordinate))
		return;
    
    if(self.isBusy)
		return;
    
    lastLatitude = self.coordinate.latitude;
    lastLongitude = self.coordinate.longitude;
	
	Pin* pin = [Pin pinWithCoordinate:self.coordinate userID:self.index];
	NSString* path = [NSString stringWithFormat:@"update_coordinates"];
	NSDictionary* params = [pin dictionaryPresentation];
    
    //NSLog(@"update_coordinates, send to server. request: %@", params);
    
    NSData* data1 = [NSPropertyListSerialization dataFromPropertyList:params format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    [Model sharedInstance].totalUploadBytes = [data1 length];
	
	self.isBusy = YES;
	[[Model sharedInstance].httpClient postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSDictionary* result = responseObject;
         //NSLog(@"response: %@", result);
         
         NSData* data2 = [NSPropertyListSerialization dataFromPropertyList:result format: NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
         [Model sharedInstance].totalDownloadBytes = [data2 length];
         
         if (![[result objectForKey:@"success"] boolValue])
         {
             NSLog(@"%@", [[Model sharedInstance].errorTranslator descriptionForError:[[result objectForKey:@"error"] intValue]]);
             return;
         }
         
         self.isBusy = NO;
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"failure, onUpdatePin, responce: %@", [operation responseString]);
         [Model sharedInstance].totalDownloadBytes = [operation.responseString length];
         self.isBusy = NO;
     }];
}

-(void) updatePinIsActive:(BOOL)active
{
    //NSLog(@"updatePinIsActive");
	if (active)
	{
		NSInteger timeout = [[Model sharedInstance].settings timeoutForRequestsFrequency];
		if (timeout == -1)
		{
			[self.pinTimer invalidate];
			self.pinTimer = nil;
		}
		else if(!self.pinTimer)
		{
			self.pinTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(onUpdatePin:) userInfo:nil repeats:YES];
	
            //NSLog(@"[self onUpdatePin:nil];");
			//[self onUpdatePin:nil];
		}
	}
	else
	{
		[self.pinTimer invalidate];
		self.pinTimer = nil;
	}
    
	self.isUpdatePinActive = active;
}

-(void) setBackgroundModeActive:(BOOL)theBackgroundModeActive
{
	if (backgroundModeActive == theBackgroundModeActive)
    {
        return;
    }
	
	backgroundModeActive = theBackgroundModeActive;
    
	if (backgroundModeActive)
	{
		self.previousValue = self.isUpdatePinActive;
		if (self.previousValue)
		{
			[self updatePinIsActive:NO];
			[self updatePinIsActive:YES];
		}
	}
	else
	{
		if (self.previousValue)
		{
			[self updatePinIsActive:NO];
			[self updatePinIsActive:YES];
		}
	}
}

- (NSString*) distanceFromLocation:(CLLocation*)fromLocation kmHOnly:(BOOL)kmHOnly
{
	NSString* distanceString = nil;
	CLLocation* location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
	CLLocationDistance distance = [fromLocation distanceFromLocation:location];
    
	if(distance < 1000.f && !kmHOnly)
    {
        distanceString = [NSString stringWithFormat:@"%.1f meters", distance];
    }
	else
    {
        distanceString = [NSString stringWithFormat:@"%.1f kilometers", distance / 1000.f];
    }
	
	return distanceString;
}

#pragma mark - Properties

- (NSUInteger) status
{
    return status;
}

- (void) setStatus:(NSUInteger)theStatus
{
    status = theStatus;
}

- (void (^)())onUpdateCoordinatesBlock
{
    return onUpdateCoordinatesBlock;
}

- (void) setOnUpdateCoordinatesBlock:(void (^)())theOnUpdateCoordinatesBlock
{
    onUpdateCoordinatesBlock = theOnUpdateCoordinatesBlock;
}

- (NSTimer*) pinTimer
{
    return pinTimer;
}

- (void) setPinTimer:(NSTimer *)thePinTimer
{
    pinTimer = thePinTimer;
}

- (BOOL) isUpdatePinActive
{
    return isUpdatePinActive;
}

- (void) setIsUpdatePinActive:(BOOL)theIsUpdatePinActive
{
    isUpdatePinActive = theIsUpdatePinActive;
}

- (CLLocationCoordinate2D) coordinate
{
    return coordinate;
}

-(void) setCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    //NSLog(@"setCoordinate");
	if (!CLLocationCoordinate2DIsValid(coordinate))
    {
        return;
    }
	
	coordinate = theCoordinate;
	NSInteger timeout = [[Model sharedInstance].settings timeoutForRequestsFrequency];
    
	if (timeout == -1 && self.isUpdatePinActive)
    {
        //NSLog(@"[self onUpdatePin:nil];");
        //!!![self onUpdatePin:nil];
    }
	
	if (self.onUpdateCoordinatesBlock)
    {
        self.onUpdateCoordinatesBlock();
    }
}

- (BOOL) isBusy
{
    return isBusy;
}

- (void) setIsBusy:(BOOL)theIsBusy
{
    isBusy = theIsBusy;
}

- (BOOL) previousValue
{
    return previousValue;
}

- (void) setPreviousValue:(BOOL)thePreviousValue
{
    previousValue = thePreviousValue;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) imageLoadDidFinish:(UIImageView*)imageView
{
    UIImage* image = [UIImage imageWithData:self.imageAvatar];
    
    UIImage* resizedImage = [DBUser imageWithImage:image scaledToSize:imageView.frame.size];
    
    if (imageView)
    {
        imageView.image = resizedImage;
        imageView.hidden = NO;
    }
    
    [Model sharedInstance].totalDownloadBytes = [self.imageAvatar length];
    
    [activity stopAnimating];
    if ([delegate respondsToSelector:@selector(didImageLoad:image:)])
    {
        [delegate performSelector:@selector(didImageLoad:image:) withObject:self withObject:resizedImage];
    }
}

- (void) loadImage:(UIImageView*)imageView
{
    NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
    self.imageAvatar = imageData;
    
    [self performSelectorOnMainThread:@selector(imageLoadDidFinish:) withObject:imageView waitUntilDone:NO];
}

- (void) imageInBackground:(UIImageView*)imageView
{
    if (self.imageAvatar)
    {
        UIImage* image = [UIImage imageWithData:self.imageAvatar];
        
        UIImage* resizedImage = [DBUser imageWithImage:image scaledToSize:imageView.frame.size];
        imageView.image = resizedImage;
        imageView.hidden = NO;
    }
    else if ([self.imageUrl length] > 0)
    {
        activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activity.frame = CGRectMake(imageView.frame.size.width / 2 - 15.0, imageView.frame.size.height / 2 - 15.0, 30.0, 30.0);
        [imageView addSubview:activity];
        [activity startAnimating];
        
        [self performSelectorInBackground:@selector(loadImage:) withObject:imageView];
    }
    else
    {
        imageView.image = [UIImage imageNamed:@"photo_box.png"];
    }
}

- (void) addMyGroup:(DBGroup*)group
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

- (UIImage*) imageInMarker
{
    if ([self.imageAvatar length] > 0)
    {
        UIImage* frameImage = [UIImage imageNamed:@"pin_photo.png"];
        UIImage* avatar = [UIImage imageWithData:self.imageAvatar];
        UIImage* markerImage = [frameImage drawImage:avatar inRect:CGRectMake(2.0, 2.0, 42.0, 40.0)];
        
        return markerImage;
    }
    
    return [UIImage imageNamed:@"pin_me.png"];
}

@end
