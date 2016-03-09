//
//  SettingsVC.h
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectionVC;

@interface SettingsVC : BaseVC
{
	enum
	{
		SelectionModeLanguage,
		SelectionModePollingFrequency,
		SelectionModeActiveInBackground,
		SelectionModeCount
	}_pickerViewMode;

	NSArray* _modeStrings[SelectionModeCount];				
}

@property (weak, nonatomic) IBOutlet UIButton *buttonLanguage;
@property (weak, nonatomic) IBOutlet UIButton *buttonPollingFrequency;
@property (weak, nonatomic) IBOutlet UIButton *buttonActiveInBackground;

- (IBAction) onClose:(id)sender;
- (IBAction) onSelectLanguage;
- (IBAction) onSelectPollingFrequency;
- (IBAction) onSelectActiveInBackground;
- (IBAction) onMyGroups;

@end
