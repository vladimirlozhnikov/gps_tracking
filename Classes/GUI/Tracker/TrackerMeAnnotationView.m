//
//  TrackerMeAnnotationView.m
//  GPSTracker
//
//  Created by YS on 3/12/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerMeAnnotationView.h"
#import "TrackerClusterAnnotation.h"
#import "DBUser+Methods.h"

@implementation TrackerMeAnnotationView

+ (UIView*) view:(DBUser*)user
{
    UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_field.png"]];
    imageBG.frame = CGRectMake(0, 0, 60, 30);
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = NO;
    
	[view addSubview:imageBG];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 60, 20)];
	title.textColor = [UIColor redColor];
	title.backgroundColor = [UIColor clearColor];
	title.font = [UIFont systemFontOfSize:16];
	title.textAlignment = UITextAlignmentCenter;
	title.adjustsFontSizeToFitWidth = YES;
    title.minimumFontSize = 9;
	title.text = @"You";
    
	[view addSubview:title];
    
	return view;
}

- (UILabel*) createLabelWithFrame:(CGRect)rc
{
	UILabel* label = [[UILabel alloc] initWithFrame:rc];
    
	label.textColor = [UIColor whiteColor];
	label.backgroundColor = [UIColor clearColor];
	label.font = [UIFont systemFontOfSize:16];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = YES;
	label.minimumFontSize = 9;
    
	return label;
}

- (UIView*) createView
{
	UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"you_pin.png"]];
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = NO;

	[view addSubview:imageBG];
	
	_labelTitle = [self createLabelWithFrame:CGRectMake(2, 5, 40, 20)];
	_labelTitle.text = @"You";
	[view addSubview:_labelTitle];
    
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

- (NSString*) description
{
	DBUser* user = ((TrackerMeAnnotation*)self.annotation).user;
	return [NSString stringWithFormat:@"%@: %.3f %.3f", user.nickName, user.coordinate.latitude, user.coordinate.longitude];
}

@end
