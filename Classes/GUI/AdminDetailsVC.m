//
//  UserDetailsVC.m
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "AdminDetailsVC.h"
#import "DBUser+Methods.h"
#import "Model.h"

@implementation AdminDetailsVC

- (void) viewDidUnload
{
	[self setLabelFirstName:nil];
	[self setLabelLastName:nil];
	[self setLabelNickName:nil];
	[self setLabelEmail:nil];
	[self setLabelPhoneNumber:nil];
	[self setImageAvatar:nil];
    
	[super viewDidUnload];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) emailClicked:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController* mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        NSArray* toRecipients = [NSArray arrayWithObjects:self.user.email, nil];
        [mailer setToRecipients:toRecipients];
        [self presentModalViewController:mailer animated:YES];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

- (IBAction) telClicked:(id)sender
{
    if ([self.user.phoneNumber length] > 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", self.user.phoneNumber]]];
    }
}

- (void) viewDidLoad
{
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"User information"]];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.labelFirstName.text = self.user.firstName;
	self.labelLastName.text = self.user.lastName;
	self.labelNickName.text = self.user.nickName;
	self.labelEmail.text = self.user.email;
	self.labelPhoneNumber.text = self.user.phoneNumber;
    
    [self.user imageInBackground:self.imageAvatar];
}

@end
