//
//  ReadMessageVC.m
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "ReadMessageVC.h"
#import "DBMessage+Methods.h"
#import "DBUser+Methods.h"
#import "DBAttachment+Methods.h"
#import "Model.h"
#import "DateUtils.h"
#import "TrackerUserVC.h"

@interface ReadMessageVC ()

@end

@implementation ReadMessageVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Message history"]];
    
    // resize message image
    UIImage* selectMessaheImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeMessageImage = [selectMessaheImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.messageView.image = resizeMessageImage;
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.imageView addGestureRecognizer:singleTap];
    [self.imageView setUserInteractionEnabled:YES];
}

- (void) viewDidUnload
{
    [self setLabelDate:nil];
    [self setLabelUsername:nil];
    [self setTextViewMessage:nil];
    [self setImageView:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.labelUsername.text = [NSString stringWithFormat:@"%@ %@", self.message.from.firstName, self.message.from.lastName];
	self.labelDate.text = [DateUtils stringFromDate:self.message.friendlyDate];
	self.textViewMessage.text = self.message.text;
    [self.message.attachment imageInBackground:self.imageView];
    self.message.isUnread = [NSNumber numberWithBool:NO];
    
    NSInteger unreadCount = [[[Model sharedInstance].myMessages unreadMessages] count];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unreadCount];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    TrackerUserVC* vc = (TrackerUserVC*)segue.destinationViewController;
    vc.user = self.message.from;
    vc.group = DELEGATE.currentGroup;
}

- (void)bannerTapped:(UIGestureRecognizer *)gestureRecognizer
{
    expanded = !expanded;
    
    [UIView beginAnimations:@"expandcollapse" context:nil];
    [UIView setAnimationDuration:0.5];
    
    CGRect frame = expanded ? CGRectMake(10.0, 18.0, self.view.frame.size.width - 30.0, self.view.frame.size.height - 46.0) : CGRectMake(15.0, 23.0, 120.0, 132.0);
    self.imageView.frame = frame;
    
    [UIView commitAnimations];
}

@end
