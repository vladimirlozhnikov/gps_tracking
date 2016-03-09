//
//  SendMessageVC.h
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DBGroup;

@interface AlertMessageVC : BaseVC<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
{
}

@property (nonatomic, weak) DBGroup* group;
@property (nonatomic, weak) NSArray* users;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *tableImage;
@property (weak, nonatomic) IBOutlet UIImageView *attachImage;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIButton *buttonSend;
@property (weak, nonatomic) IBOutlet UIButton* buttonAttachment;

- (IBAction) onClose:(id)sender;
- (IBAction) onSelectPhoto;
- (IBAction) onSend;
- (IBAction) onRemovePhoto;

@end
