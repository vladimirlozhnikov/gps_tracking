//
//  LoginVC.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Protocol.h"

@interface LoginVC : BaseVC<UITextFieldDelegate, FBLoginViewDelegate, TrafficProtocol>

@property (weak, nonatomic) IBOutlet UITextField *textFieldLogin;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UIButton* buttonVKontakte;
@property (weak, nonatomic) IBOutlet UILabel* rememberLabel;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;
@property (weak, nonatomic) IBOutlet UIButton *buttonForgotPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonRegistration;
@property (weak, nonatomic) IBOutlet UIButton *buttonSettings;
@property (weak, nonatomic) IBOutlet UILabel* trafficInLabel;
@property (weak, nonatomic) IBOutlet UILabel* trafficOutLabel;

- (IBAction) onLogin;
- (IBAction) onRememberPassword:(id)sender;
- (IBAction) onFacebookLogin;
- (IBAction) onSettings;

@end
