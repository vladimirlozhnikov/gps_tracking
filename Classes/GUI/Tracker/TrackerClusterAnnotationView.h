//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class DBGroup;

@interface TrackerClusterAnnotationView : MKAnnotationView <MKAnnotation>
{
	UIView* _view;
	UIImageView* _imageFlag;
}

@property (nonatomic, weak) DBGroup* group;

@end
