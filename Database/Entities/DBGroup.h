//
//  DBGroup.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBCity, DBColor, DBCountry, DBUser;

@interface DBGroup : NSManagedObject
{
    __weak DBUser *owner;
    NSMutableArray* users;
    NSInteger usersCount;
}

@property (nonatomic, strong) NSString * desc;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSData * imageFlag;
@property (nonatomic, strong) NSString * ind;
@property (nonatomic, strong) NSNumber * isOpen;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * nickname;
@property (nonatomic, strong) NSString * ticket;
@property (nonatomic, strong) DBCity *city;
@property (nonatomic, strong) DBColor *color;
@property (nonatomic, strong) DBCountry *country;
@end

@interface DBGroup (CoreDataGeneratedAccessors)

@end
