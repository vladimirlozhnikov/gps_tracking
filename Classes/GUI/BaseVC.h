//
//  BaseVC.h
//  GPSTracker
//
//  Created by YS on 1/9/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseVC : UIViewController
{
}

@property (nonatomic) float duration;
@property (nonatomic) float delay;
@property (nonatomic) BOOL isAnimationEnabled;

-(void) pushAnimation:(void (^)(void))push;
-(void) popAnimation:(void (^)(void))pop;

@end
