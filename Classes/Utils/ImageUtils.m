//
//  ImageUtils.m
//  GPSTracker
//
//  Created by YS on 3/16/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "ImageUtils.h"

@implementation ImageUtils

+ (UIImage*)imageWithLowQuality:(UIImage*)image
{
    //NSLog(@"imageWithLowQuality");
    if (image)
    {
        //NSLog(@"image is not nil");
        
        //CGSize newSize = image.size;
        CGSize newSize;
        CGSize sz = image.size;
        float scale;
        if(sz.width > sz.height)
            scale = 640.f / sz.width;
        else
            scale = 960 / sz.height;
		
        newSize = CGSizeMake(sz.width * scale, sz.height * scale);
        //NSLog(@"images size: %f, %f", newSize.width, newSize.height);
        return [ImageUtils imageWithImage:image scaledToSize:newSize];
    }
    
    return nil;
}

+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    //NSLog(@"imageWithImage");
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imgData = UIImageJPEGRepresentation(newImage, 0);
    UIImage* lowImage = [UIImage imageWithData:imgData];
    UIGraphicsEndImageContext();
    return lowImage;
}

@end
