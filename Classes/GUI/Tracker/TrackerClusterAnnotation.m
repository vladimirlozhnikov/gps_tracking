//
//  TrackerClusterPin.m
//  GPSTracker
//
//  Created by YS on 1/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerClusterAnnotation.h"
#import "DBUser+Methods.h"

@implementation TrackerMeAnnotation

@end

@implementation TrackerClusterAnnotation

- (CLLocationCoordinate2D) coordinate
{
	return _user.coordinate;
}

-(void) setUser:(DBUser *)user
{
	_user = user;
	self.coordinate = _user.coordinate;
}

- (DBUser*) user
{
	return _user;
}

@end

@implementation TrackerRouteAnnotation

- (void) setCoordinate:(CLLocationCoordinate2D)theCoordinate
{
    [super setCoordinate:theCoordinate];
}

- (CLLocationCoordinate2D) coordinate
{
	return coordinate;
}

@end
