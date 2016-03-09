//
//  TrackerRouteAnnotationView.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 10.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerRouteAnnotationView.h"

@implementation TrackerRouteAnnotationView

- (UIView*) createView
{
	UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_pin.png"]];
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	[view addSubview:imageBG];
    
	return view;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
    {
		UIView* view = [self createView];
		[self addSubview:view];
		self.frame = view.frame;
        self.centerOffset = CGPointMake(0, -view.frame.size.height / 2.f);
    }
    
    return self;
}

@end
