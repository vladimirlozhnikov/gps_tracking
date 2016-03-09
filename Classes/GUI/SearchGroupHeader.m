//
//  SearchGroupHeader.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 13.06.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SearchGroupHeader.h"

@implementation SearchGroupHeader
@synthesize buttonName, labelType, cityLabel, index;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction) onName
{
    [self.delegate searchGroupCellOnName:self];
}

@end
