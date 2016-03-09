//
//  BaseVC.m
//  GPSTracker
//
//  Created by YS on 1/9/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"

@implementation BaseVC

#define DEFAULT_DURATION 0.75f;
#define DEFAULT_DELAY 0.375f;

#define TEXT_FIELD_OFFSET 10.f
#define KEYBOARD_HEIGHT 220.f
#define NON_KEYBOARD_AREA_HEIGHT (self.view.frame.size.height - KEYBOARD_HEIGHT - TEXT_FIELD_OFFSET)

-(id) initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		self.duration = DEFAULT_DURATION;
		self.delay = DEFAULT_DELAY;
		self.isAnimationEnabled = YES;
	}
    
	return self;
}

-(void) pushAnimation:(void (^)(void))push
{
	if (!self.isAnimationEnabled)
	{
		push();
		return;
	}
		
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:self.duration];
	push();
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
						   forView:self.navigationController.view cache:NO];
	[UIView commitAnimations];
}

-(void) popAnimation:(void (^)(void))pop
{
	if (!self.isAnimationEnabled)
	{
		pop();
		return;
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:self.duration];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
						   forView:self.navigationController.view cache:NO];
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:self.delay];
	pop();
	[UIView commitAnimations];
}

#pragma mark UITextField autoscroll
- (void) beginAnimation:(NSNumber*)yBottom
{
	[UIView animateWithDuration:0.2 animations:^()
	 {
		 [UIView setAnimationBeginsFromCurrentState:YES];
		 float yDif = NON_KEYBOARD_AREA_HEIGHT - [yBottom floatValue];
		 CGRect rc = self.view.frame;
		 rc.origin.y = yDif;
		 self.view.frame = rc;
	 }];
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
	if ([textField.superview isKindOfClass:[UITableViewCell class]])
    {
        return YES;
    }
	
	CGRect frame = textField.frame;
	if([self.view isKindOfClass:[UIScrollView class]])
    {
        frame = [self.view.superview convertRect:textField.frame fromView:self.view];
    }
	
	float yBottom = frame.origin.y + frame.size.height;
	if (yBottom <= NON_KEYBOARD_AREA_HEIGHT)
    {
        return YES;
    }

	[self performSelector:@selector(beginAnimation:) withObject:[NSNumber numberWithFloat:yBottom] afterDelay:0.f];
    
	return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField
{
	if ([textField.superview isKindOfClass:[UITableViewCell class]])
    {
        return YES;
    }

	float yBottom = textField.frame.origin.y + textField.frame.size.height;
	if (yBottom <= NON_KEYBOARD_AREA_HEIGHT)
    {
        return YES;
    }

	[UIView animateWithDuration:0.2 animations:^()
	 {
		 [UIView setAnimationBeginsFromCurrentState:YES];
		 CGRect rc = self.view.frame;
		 rc.origin.y = 0;
		 self.view.frame = rc;
	 }];
    
	return YES;
}

@end
