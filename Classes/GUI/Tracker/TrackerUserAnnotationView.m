//
//  TrackerUserAnnotationView.m
//  GPSTracker
//
//  Created by YS on 1/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerUserAnnotationView.h"
#import "DBUser+Methods.h"
#import <QuartzCore/QuartzCore.h>
#import "TrackerClusterAnnotation.h"

@implementation TrackerUserAnnotationView

+ (UIView*) view:(DBUser*)user
{
    UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_field.png"]];
    imageBG.frame = CGRectMake(0, 0, 90, 30);
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = NO;
	
	[view addSubview:imageBG];
    
	UIImageView* imageAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(2, 1.5f, 28, 28)];
    [user imageInBackground:imageAvatar];
	[view addSubview:imageAvatar];
    
	UILabel* labelFirstName = [[UILabel alloc] initWithFrame:CGRectMake(30, 2, 50, 10)];
	labelFirstName.textColor = [UIColor blackColor];
	labelFirstName.backgroundColor = [UIColor clearColor];
	labelFirstName.font = [UIFont systemFontOfSize:10];
	labelFirstName.textAlignment = UITextAlignmentCenter;
	labelFirstName.adjustsFontSizeToFitWidth = YES;
	labelFirstName.minimumFontSize = 9;
    labelFirstName.text = user.firstName;
	[view addSubview:labelFirstName];
	
	UILabel* labelLastName = [[UILabel alloc] initWithFrame:CGRectMake(30, 13, 50, 10)];
	labelLastName.textColor = [UIColor blackColor];
	labelLastName.backgroundColor = [UIColor clearColor];
	labelLastName.font = [UIFont systemFontOfSize:10];
	labelLastName.textAlignment = UITextAlignmentCenter;
	labelLastName.adjustsFontSizeToFitWidth = YES;
	labelLastName.minimumFontSize = 9;
    labelLastName.text = user.lastName;
	[view addSubview:labelLastName];
	
	return view;
}

- (UILabel*) createLabelWithFrame:(CGRect)rc
{
	UILabel* label = [[UILabel alloc] initWithFrame:rc];
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:10];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 9;
    
	return label;
}

- (UIView*) createView
{
	UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_pin.png"]];
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = NO;
	
	[view addSubview:imageBG];
		
	_imageAvatar = [[UIImageView alloc] initWithFrame:CGRectMake(2, 1.5f, 28, 28)];
	[view addSubview:_imageAvatar];
		
	_labelFirstName = [self createLabelWithFrame:CGRectMake(31, 2, 55, 10)];
	[view addSubview:_labelFirstName];
	
	_labelLastName = [self createLabelWithFrame:CGRectMake(31, 17, 55, 10)];
	[view addSubview:_labelLastName];
	
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

- (void) layoutSubviews
{
	[super layoutSubviews];
	DBUser* user = ((TrackerClusterAnnotation*)self.annotation).user;
    [user imageInBackground:_imageAvatar];
	_labelFirstName.text = user.firstName;
	_labelLastName.text = user.lastName;
}

- (NSString*) description
{
	DBUser* user = ((TrackerClusterAnnotation*)self.annotation).user;
	return [NSString stringWithFormat:@"%@: %.3f %.3f", user.nickName, user.coordinate.latitude, user.coordinate.longitude];
}

@end
