//
//  LoginVC.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "LoginVC.h"
#import "Model.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "DBUser+Methods.h"

@implementation LoginVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    ((UIScrollView*)self.view).contentSize = CGSizeMake(320.0, 576.0);
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Log in"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"top_bar.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.textFieldLogin.text = [Model sharedInstance].credentials.username;
	self.textFieldPassword.text = [Model sharedInstance].credentials.password;
	self.buttonLogin.enabled = [[Model sharedInstance].credentials isFilled];
	self.rememberSwitch.on = [Model sharedInstance].credentials.isRemember;
    
    self.trafficInLabel.text = [[Model sharedInstance].settings friendlyDownloadTraffic];
    self.trafficOutLabel.text = [[Model sharedInstance].settings friendlyUploadTraffic];
}

- (IBAction) onLogin
{
	[self.textFieldLogin resignFirstResponder];
	[self.textFieldPassword resignFirstResponder];
	[self saveIfRememberOn];

	[DELEGATE showActivity];
	[[Model sharedInstance] loginWithSuccess:^()
	{
		[DELEGATE hideActivity];
		UIViewController* vc = [DELEGATE controllerWithName:@"SearchGroupVC" fromStoryboard:@"GroupStoryboard"];
		[self.navigationController pushViewController:vc animated:YES];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (IBAction) onFacebookLogin
{
	if (!FBSession.activeSession.isOpen)
	{
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"LoginVC" withAction:@"onFacebookLogin" withLabel:@"register_facebook" withValue:nil];
		[DELEGATE showActivity];
		[FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error)
		{
			if(error)
            {
                [DELEGATE hideActivity];
            }
			else
            {
                [self getPermissions];
            }
		}];
	}
	else
	{
		[DELEGATE showActivity];
		[self getPermissions];
	}
}

- (IBAction) onSettings
{
    [self saveIfRememberOn];
    
	UIViewController* vc = [DELEGATE controllerWithName:@"SettingsVC" fromStoryboard:@"SettingsStoryboard"];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) getPermissions
{
	if ([FBSession.activeSession.permissions indexOfObject:@"email"] == NSNotFound)
	{
		[FBSession.activeSession reauthorizeWithReadPermissions:@[@"email"] completionHandler:^(FBSession *session, NSError *error)
		 {
			 if(error)
             {
                 [DELEGATE hideActivity];
             }
			 else
             {
                 [self getInfo];
             }
		 }];
	}
	else
	{
		[self getInfo];
	}
}

- (void) getInfo
{
	[[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *fbuser, NSError *error)
	 {
		 if (!error)
		 {
             BOOL registered = [[[NSUserDefaults standardUserDefaults] objectForKey:@"registered"] boolValue];
             
			 DBUser* user = [DBUser userWithFirstName:fbuser.first_name lastName:fbuser.last_name email:[fbuser objectForKey:@"email"]];
			 user.nickName = fbuser.username;
             
             if (!registered)
             {
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbuser.id]];
                 NSData* data = [NSData dataWithContentsOfURL:url];
                 
                 if (data)
                 {
                     user.imageAvatar = data;
                 }
             }
			 
			 [DELEGATE showActivity];
			 [user registerWithSuccess:^(NSDictionary* response)
			 {
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"registered"];
                 
                 NSString* error = [response objectForKey:@"error"];
                 if ([error integerValue] == 14)
                 {
                     NSString* session = [response objectForKey:@"session"];
                     NSDictionary* user = [response objectForKey:@"user"];
                     
                     [Model sharedInstance].credentials.username = [user objectForKey:@"email"];
                     self.rememberSwitch.on = NO;
                     self.textFieldLogin.text = [Model sharedInstance].credentials.username;
                     
                     [Model sharedInstance].credentials.isRemember = NO;
                     [[Model sharedInstance].credentials save];
                     
                     [[Model sharedInstance] login:user session:session success:^{
                         [DELEGATE hideActivity];
                         UIViewController* vc = [DELEGATE controllerWithName:@"SearchGroupVC" fromStoryboard:@"GroupStoryboard"];
                         [self.navigationController pushViewController:vc animated:YES];
                     } onError:^(NSString *error) {
                         [DELEGATE hideActivity];
                         [DELEGATE showAlertWithMessage:error];
                     }];
                 }
                 else
                 {
                     self.textFieldLogin.text = [Model sharedInstance].credentials.username;
                     self.textFieldPassword.text = [Model sharedInstance].credentials.password;
                     self.buttonLogin.enabled = YES;
                     
                     [DELEGATE hideActivity];
                     [DELEGATE showAlertWithMessage:@"Registration successfully"];
                 }
			 }
			 onError:^(NSString* error)
			 {
				[DELEGATE showAlertWithMessage:error];
				[DELEGATE hideActivity];
			 } saveAvatar:!registered];
		 }
		 else
         {
             [DELEGATE hideActivity];
         }
	 }];
}

- (IBAction) onRememberPassword:(id)sender
{
    [Model sharedInstance].credentials.isRemember = self.rememberSwitch.on;
	[self saveIfRememberOn];
}

- (void) viewDidUnload
{
	[self setTextFieldLogin:nil];
	[self setTextFieldPassword:nil];
	[self setButtonLogin:nil];
	[super viewDidUnload];
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL bFirstFilled = ([textField.text length] + [string length] - range.length) > 0;
	BOOL bSecondFilled = NO;
	
	if(textField != self.textFieldLogin)
		bSecondFilled = [self.textFieldLogin.text length];
	else
		bSecondFilled = [self.textFieldPassword.text length];
	
	self.buttonLogin.enabled = bFirstFilled && bSecondFilled;
	
	return YES;
}

#pragma mark - Private Methods

- (void) saveIfRememberOn
{
    if ([Model sharedInstance].credentials.isRemember)
    {
        [Model sharedInstance].credentials.username = self.textFieldLogin.text;
        [Model sharedInstance].credentials.password = self.textFieldPassword.text;
        [Model sharedInstance].credentials.isRemember = self.rememberSwitch.on;
        [[Model sharedInstance].credentials save];
    }
}

#pragma mark - TrafficProtocol

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload
{
    self.trafficInLabel.text = friendlyDownload;
    self.trafficOutLabel.text = friendlyUpload;
}

@end
