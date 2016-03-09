//
//  Color.h
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Color : NSObject

@property(nonatomic) float red;
@property(nonatomic) float green;
@property(nonatomic) float blue;

+ (UIColor*) colorWithHexString:(NSString*)hex;
+ (NSString*) hexStringWithColor:(UIColor*)color;

@end
