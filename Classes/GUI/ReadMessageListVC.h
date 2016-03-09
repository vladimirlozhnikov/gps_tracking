//
//  ReadMessageListVC.h
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Protocol.h"

@interface ReadMessageListVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* messages;
}

@property (weak, nonatomic) IBOutlet UILabel *labelAllMessagesCount;
@property (weak, nonatomic) IBOutlet UILabel *labelUnreadMessagesCount;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *tableImage;
@property (weak) id <ReadMessageListVCDelegate> delegate;

- (IBAction) onClose:(id)sender;

@end
