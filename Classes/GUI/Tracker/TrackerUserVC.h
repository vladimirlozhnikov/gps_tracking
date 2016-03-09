//
//  UserVC.h
//  GPSTracker
//
//  Created by YS on 2/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"

@class DBUser;
@class DBGroup;

@interface TrackerUserVC : BaseVC<UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextViewDelegate>
{
	BOOL _isInited;
    BOOL isAvatarAssiged;
}

@property (nonatomic, weak) DBUser* user;
@property (nonatomic, weak) DBGroup* group;

@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelNickname;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UIButton *buttonMakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *buttonSendMessage;
@property (weak, nonatomic) IBOutlet UIButton *buttonAttachment;
@property (weak, nonatomic) IBOutlet UIImageView *messageImage;

- (IBAction) onClose:(id)sender;
- (IBAction) onTakePhoto;
- (IBAction) onSelectPhoto;
- (IBAction) onSend;
- (IBAction) onRemovePhoto;
- (IBAction) telClicked:(id)sender;

@end
