//
//  JoinGroupVC.h
//  GPSTracker
//
//  Created by YS on 2/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"

@class DBGroup;

@interface JoinGroupVC : BaseVC<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textFieldTicket;
@property (weak, nonatomic) IBOutlet UIButton *buttonEnter;

@property(nonatomic, weak) DBGroup* group;

- (IBAction)onClose:(id)sender;
- (IBAction)onEnter;

@end
