//
//  StrikeoutButton.m
//  GPSTracker
//
//  Created by YS on 1/27/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "StrikeoutButton.h"

@implementation StrikeoutButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
	{
		self.titleLabel.textColor = [UIColor colorWithRed:62.f/255
													green:60.f/255
													 blue:57.f/255
													alpha:1.f];

		[self initImage];
//		[self addSubview:_imageViewLine];
		[self addTarget:self action:@selector(onHighlightOn) forControlEvents:UIControlEventTouchDown];
		[self addTarget:self action:@selector(onHighlightOff) forControlEvents:
		 UIControlEventTouchUpOutside |
		 UIControlEventTouchUpInside |
		 UIControlEventTouchCancel];
//		self.titleLabel.adjustsFontSizeToFitWidth = NO;
    }
    return self;
}

- (void)onHighlightOn
{
	_imageViewLine.hidden = NO;
}

- (void)onHighlightOff
{
	_imageViewLine.hidden = YES;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	NSString* text = [self titleForState:UIControlStateHighlighted];
	CGSize sz = [text sizeWithFont:self.titleLabel.font constrainedToSize:self.titleLabel.bounds.size lineBreakMode:self.titleLabel.lineBreakMode];
	CGSize szText = [text sizeWithFont:self.titleLabel.font];
	CGRect labelFrame = self.bounds;
	
	float xDif = 0;
	if(self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentCenter)
	{
		float dif = (labelFrame.size.width - szText.width);
		xDif = labelFrame.origin.x + dif / 2.f;
	}
	
	float yDif = (self.bounds.size.height - sz.height) / 2.f;
	
	float x = 0.f + xDif;
	float y = sz.height + yDif - 4;
	
	UIImage* imgSmall = [UIImage imageNamed:@"red_line_small.png"];
	if(imgSmall.size.width >= sz.width)
		_imageViewLine.image = imgSmall;
	else
		_imageViewLine.image = [UIImage imageNamed:@"red_line_long.png"];
	
	_imageViewLine.frame = CGRectMake(x, y,
									  MIN(szText.width, labelFrame.size.width),
									  _imageViewLine.frame.size.height);
}

- (void)initImage
{
	NSString* text = [self titleForState:UIControlStateHighlighted];
	CGSize sz = [text sizeWithFont:self.titleLabel.font constrainedToSize:self.titleLabel.bounds.size lineBreakMode:self.titleLabel.lineBreakMode];

	float xDif = (self.titleLabel.textAlignment == UITextAlignmentCenter) ? (self.titleLabel.bounds.size.width - sz.width) / 2 : 0;
	float yDif = (self.bounds.size.height - sz.height) / 2.f;
	
	float x = 0.f + xDif;
	float y = sz.height + yDif - 4;
		
	UIImage* imgSmall = [UIImage imageNamed:@"red_line_small.png"];
	if(imgSmall.size.width >= sz.width)
		_imageViewLine = [[UIImageView alloc] initWithImage:imgSmall];
	else
		_imageViewLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_line_long.png"]];

	_imageViewLine.frame = CGRectMake(x, y,
										_imageViewLine.frame.size.width,
										_imageViewLine.frame.size.height);
	_imageViewLine.hidden = YES;
	[self addSubview:_imageViewLine];
}

@end
