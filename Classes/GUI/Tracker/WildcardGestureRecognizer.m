//
//  WildcardGestureRecognizer.m
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "WildcardGestureRecognizer.h"

@implementation WildcardGestureRecognizer

@synthesize touchesBeganCallback, touchesMovedCallback;

-(id) init
{
    if (self = [super init])
    {
        self.cancelsTouchesInView = NO;
    }
    
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (touchesBeganCallback)
    {
        touchesBeganCallback(touches, event);
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (touchesMovedCallback)
    {
        touchesMovedCallback(touches, event);
    }
}

- (void) reset
{
}

- (void) ignoreTouch:(UITouch *)touch forEvent:(UIEvent *)event
{
}

- (BOOL) canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (BOOL) canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

@end