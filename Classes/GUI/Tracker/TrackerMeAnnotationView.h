//
//  TrackerMeAnnotationView.h
//  GPSTracker
//
//  Created by YS on 3/12/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TrackerMeAnnotationView : MKAnnotationView
{
	UILabel* _labelTitle;
}

+ (UIView*) view:(DBUser*)user;

@end
