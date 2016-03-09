//
//  SelectionVC.h
//  GPSTracker
//
//  Created by YS on 1/28/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"

@interface SelectionVC : BaseVC<UITableViewDataSource, UITableViewDelegate>
{
	__strong NSMutableIndexSet* _selectedValues;
    BOOL showAGPS;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;
@property (weak, nonatomic) IBOutlet UISwitch* agpsSwitch;
@property (weak, nonatomic) IBOutlet UILabel* agpsLabel;

@property (weak, nonatomic) NSString* title;
@property (strong, nonatomic) NSArray* values;
@property (strong, nonatomic) NSMutableIndexSet* selectedValues;

@property (nonatomic) NSInteger selectAllValue;

@property (nonatomic) BOOL isMultiSelection;
@property (nonatomic) BOOL isAnimatedBack;
@property (nonatomic) BOOL showAGPS;

@property (strong, nonatomic) NSInvocation* invocation;

- (void)onBack:(id)sender;
- (IBAction)agpsValueChanged:(id)sender;

@end
