//
//  WildcardGestureRecognizer.h
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TouchesEventBlock)(NSSet * touches, UIEvent * event);

@interface WildcardGestureRecognizer : UITapGestureRecognizer
{
    TouchesEventBlock touchesBeganCallback;
    TouchesEventBlock touchesMovedCallback;
}

@property(copy) TouchesEventBlock touchesBeganCallback;
@property(copy) TouchesEventBlock touchesMovedCallback;

@end