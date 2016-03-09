//
//  DBAttachment.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 04.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface DBAttachment : NSManagedObject
{
    UIActivityIndicatorView* activity;
}

@property (nonatomic, strong) NSData * image;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) NSString * index;
@property (nonatomic, strong) NSNumber * type;

@end
