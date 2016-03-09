//
//  UserStatisticsVC.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 09.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseVC.h"
#import "Protocol.h"

typedef enum EDateType
{
    noneType,
    fromType,
    toType
} DateType;

@interface UserStatisticsVC : BaseVC
{
    BOOL hideMode;
    DateType dateType;
}

@property (weak, nonatomic) IBOutlet UIButton* fromButton;
@property (weak, nonatomic) IBOutlet UIButton* toButton;
@property (weak, nonatomic) IBOutlet UIDatePicker* datePicker;
@property (weak, nonatomic) IBOutlet UIButton* okButton;
@property (weak, nonatomic) id <StatisticsProtocol> statisticsDelegate;
@property (weak, nonatomic) IBOutlet UILabel* fromLabel;
@property (weak, nonatomic) IBOutlet UILabel* toLabel;

@property (nonatomic, strong) NSDate* from;
@property (nonatomic, strong) NSDate* to;

- (IBAction) fromClicked:(id)sender;
- (IBAction) toClicked:(id)sender;
- (IBAction) okClicked:(id)sender;

@end
