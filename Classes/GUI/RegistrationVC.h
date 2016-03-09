//
//  RegistrationVC.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"

@interface RegistrationVC : BaseVC<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TrafficProtocol>

@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldNickname;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *selectAvatarBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatarBg;
@property (weak, nonatomic) IBOutlet UIButton *buttonSend;
@property (weak, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UILabel* trafficInLabel;
@property (weak, nonatomic) IBOutlet UILabel* trafficOutLabel;

- (IBAction) onChooseAvatar;
- (IBAction) onRegister;
- (IBAction) onClose:(id)sender;

@end
