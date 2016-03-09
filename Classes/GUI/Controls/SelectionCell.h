//
//  SelectionCell.h
//  GPSTracker
//
//  Created by YS on 1/28/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel* label;
@property (weak, nonatomic) IBOutlet UIImageView *imageTick;

@end
