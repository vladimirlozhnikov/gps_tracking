//
//  RecentAlertsVC.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentAlertCell.h"

@interface RecentAlertsVC : BaseVC<UITableViewDataSource, UITableViewDelegate,
UITextFieldDelegate, RecentAlertCellDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *textFieldText;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;

- (IBAction) onAdd;
- (IBAction) onClose:(id)sender;

@end
