//
//  DBColor.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DBColor : NSManagedObject

@property (nonatomic, strong) NSNumber * blue;
@property (nonatomic, strong) NSNumber * green;
@property (nonatomic, strong) NSNumber * red;

@end
