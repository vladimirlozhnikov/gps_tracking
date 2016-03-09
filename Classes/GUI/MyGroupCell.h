//
//  MyGroupCell.h
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UILabel *labelAdmin;
@property (weak, nonatomic) IBOutlet UIButton *buttonTickbox;

@end