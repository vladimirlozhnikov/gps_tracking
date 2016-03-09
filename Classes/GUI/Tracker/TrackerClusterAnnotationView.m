//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import "TrackerClusterAnnotationView.h"
#import "DBGroup+Methods.h"

@implementation TrackerClusterAnnotationView

- (UIView*) createView
{
	UIImageView* imageBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cluster_button.png"]];
	
	UIView* view = [[UIView alloc] initWithFrame:imageBG.bounds];
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = NO;
	
	[view addSubview:imageBG];
	
	_imageFlag = [[UIImageView alloc] initWithFrame:CGRectMake(9, 1.5f, 28, 28)];
	[view addSubview:_imageFlag];
		
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
	_imageFlag.image = [UIImage imageWithData:self.group.imageFlag];
}

@end
