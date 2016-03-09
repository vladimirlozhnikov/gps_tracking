//
//  DBCity.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBCity : NSManagedObject

@property (nonatomic, strong) NSString * index;
@property (nonatomic, strong) NSString * name;

@end
