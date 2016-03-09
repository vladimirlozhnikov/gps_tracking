//
//  MyGroupsVC.h
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGroupsVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
{
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;

- (IBAction) onClose:(id)sender;

@end
