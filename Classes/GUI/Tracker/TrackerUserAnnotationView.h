//
//  TrackerUserAnnotationView.h
//  GPSTracker
//
//  Created by YS on 1/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TrackerUserAnnotationView : MKAnnotationView
{
	UIView* _view;
	UIImageView* _imageAvatar;
	UILabel* _labelFirstName;
	UILabel* _labelLastName;
}

+ (UIView*) view:(DBUser*)user;

@end
