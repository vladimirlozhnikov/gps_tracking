//
//  UIImage+Methods.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 19.06.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UIImage+Methods.h"

@implementation UIImage (Methods)

- (UIImage *)drawImage:(UIImage *)inputImage inRect:(CGRect)frame
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    [self drawInRect:CGRectMake(0.0, 0.0, self.size.width, self.size.height)];
    [inputImage drawInRect:frame];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
