//
//  AlertMessageCell.h
//  GPSTracker
//
//  Created by YS on 3/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelMessage;
@property (weak, nonatomic) IBOutlet UIImageView *imageTick;

@end
