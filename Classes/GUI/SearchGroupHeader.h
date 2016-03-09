//
//  SearchGroupHeader.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 13.06.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"

@interface SearchGroupHeader : UITableViewCell
{
    NSInteger index;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonName;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel* cityLabel;

@property (weak, nonatomic) id<SearchGroupCellDelegate> delegate;
@property (assign) NSInteger index;

- (IBAction) onName;

@end
