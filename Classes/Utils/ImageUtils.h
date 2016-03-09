//
//  ImageUtils.h
//  GPSTracker
//
//  Created by YS on 3/16/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageUtils : NSObject

+ (UIImage*)imageWithLowQuality:(UIImage*)image;
+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
