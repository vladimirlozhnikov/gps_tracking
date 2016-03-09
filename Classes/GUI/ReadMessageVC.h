//
//  ReadMessageVC.h
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"

@class DBMessage;

@interface ReadMessageVC : BaseVC
{
    BOOL expanded;
}

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UITextView *textViewMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *messageView;

@property (weak, nonatomic) DBMessage* message;

- (IBAction) onClose:(id)sender;

@end
