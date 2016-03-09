//
//  UserDetailsVC.h
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"
#import <MessageUI/MessageUI.h>

@class DBUser;

@interface AdminDetailsVC : BaseVC <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelNickName;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imageAvatar;
@property (weak, nonatomic) DBUser* user;

- (IBAction) onClose:(id)sender;
- (IBAction) emailClicked:(id)sender;
- (IBAction) telClicked:(id)sender;

@end
