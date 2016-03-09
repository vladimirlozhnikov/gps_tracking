//
//  JoinGroupVC.m
//  GPSTracker
//
//  Created by YS on 2/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "JoinGroupVC.h"
#import "DBGroup+Methods.h"
#import "TrackerVC.h"
#import "Model.h"
#import "TypeUtils.h"

@implementation JoinGroupVC

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.buttonEnter.enabled = NO;
}

- (void) viewDidLoad
{
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Access to your group"]];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onEnter
{
	[DELEGATE showActivity];
	[self.group joinWithTicket:self.textFieldTicket.text onSuccess:^()
	{
		[self.group updateUsersWithCriteria:@"" withSuccess:^
		{
			[Model sharedInstance].updateManager.activeGroup = self.group;
			[DELEGATE.me updatePinIsActive:YES];
			[[Model sharedInstance].updateManager pingIsActive:YES frequency:[Model sharedInstance].settings.requestsFrequency];
			
			[DELEGATE hideActivity];
            [DELEGATE.me addMyGroup:self.group];
			TrackerVC* vc = (TrackerVC*)[DELEGATE controllerWithName:@"TrackerVC" fromStoryboard:@"TrackerStoryboard"];
			vc.group = self.group;
			DELEGATE.currentGroup = self.group;
			[self.navigationController pushViewController:vc animated:YES];
		}
		onError:^(NSString *error)
		{
			[DELEGATE hideActivity];
			[DELEGATE showAlertWithMessage:error];
		}];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) viewDidUnload
{
	[self setTextFieldTicket:nil];
	[self setButtonEnter:nil];
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
	BOOL bFilled = ([textField.text length] + [string length] - range.length) > 0;
	self.buttonEnter.enabled = bFilled;	
	return YES;
}

@end
