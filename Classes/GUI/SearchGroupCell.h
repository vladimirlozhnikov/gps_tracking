//
//  SearchGroupCell.h
//  GPSTracker
//
//  Created by YS on 1/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"

@interface SearchGroupCell : UITableViewCell
{
    NSInteger index;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonOwner;
@property (weak, nonatomic) IBOutlet UIButton *buttonUsers;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

@property (weak, nonatomic) id<SearchGroupCellDelegate> delegate;
@property (assign) NSInteger index;

- (IBAction) onOwner;
- (IBAction) onUsers;
- (IBAction) onLogin;

@end
