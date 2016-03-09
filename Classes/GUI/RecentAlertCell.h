//
//  RecentAlertCell.h
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecentAlertCell;

@protocol RecentAlertCellDelegate <NSObject>

-(void) recentAlertCell:(RecentAlertCell*)cell didChangeText:(NSString*)text;

@end

@interface RecentAlertCell : UITableViewCell<UITextFieldDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, weak) id<RecentAlertCellDelegate> delegate;

@end
