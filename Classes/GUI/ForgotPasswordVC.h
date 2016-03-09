//
//  ForgotPasswordVC.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordVC : BaseVC<UITextFieldDelegate>
{
}

@property (weak, nonatomic) IBOutlet UIButton *buttonSend;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

- (IBAction)onSend;
- (IBAction)onClose:(id)sender;

@end
