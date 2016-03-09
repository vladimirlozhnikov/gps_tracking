//
//  ForgotPasswordVC.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "ForgotPasswordVC.h"
#import "Model.h"

@implementation ForgotPasswordVC

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.textFieldEmail.text = [Model sharedInstance].credentials.username;
	self.buttonSend.enabled = [[Model sharedInstance].credentials.username length];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Retrieve my password"]];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (IBAction) onSend
{
	[DELEGATE showActivity];
	[self.textFieldEmail resignFirstResponder];
	[[Model sharedInstance] resetPasswordWithEmail:self.textFieldEmail.text
	onSuccess:^()
	{
		[DELEGATE hideActivity];
		[self.navigationController popViewControllerAnimated:YES];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) viewDidUnload
{
    [self setButtonSend:nil];
	[self setTextFieldEmail:nil];
    [super viewDidUnload];
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	self.buttonSend.enabled = ([textField.text length] + [string length] - range.length) > 0;
	return YES;
}

@end
