//
//  TrackerCell.h
//  GPSTracker
//
//  Created by YS on 1/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrackerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView* backgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView* imageView;
@property (weak, nonatomic) IBOutlet UILabel *labelUserInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;

@end
