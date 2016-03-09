//
//  TrackerClusterPin.h
//  GPSTracker
//
//  Created by YS on 1/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "REVClusterPin.h"

@class DBUser;

@interface TrackerClusterAnnotation : REVClusterPin
{
	DBUser* _user;
}

@property(nonatomic, weak) DBUser* user;

@end

@interface TrackerMeAnnotation : TrackerClusterAnnotation

@end

@interface TrackerRouteAnnotation : TrackerClusterAnnotation

@end