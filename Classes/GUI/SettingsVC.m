//
//  SettingsVC.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SettingsVC.h"
#import "SelectionVC.h"
#import "Model.h"
#import "LoginVC.h"

@interface SettingsVC()

@property(nonatomic, weak) SelectionVC* selectionVC;

@end

@implementation SettingsVC

- (void) changeLanguage
{
	Language language = (Language)[self.selectionVC.selectedValues lastIndex];
	[Model sharedInstance].settings.language = language;
    [[Model sharedInstance].settings save];
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"SettingsVC" withAction:@"changeLanguage" withLabel:@"language" withValue:[NSNumber numberWithInt:language]];
	
	UIViewController* vc1 = [DELEGATE controllerWithName:@"LoginVC" fromStoryboard:@"AuthorizationStoryboard"];
	SettingsVC* vc2 = (SettingsVC*)[DELEGATE controllerWithName:@"SettingsVC" fromStoryboard:@"SettingsStoryboard"];
	vc2.selectionVC = self.selectionVC;
	
	NSMutableArray* vcs = [NSMutableArray arrayWithObjects:vc1, vc2, nil];
	
	for (UIViewController* vc in [self.navigationController viewControllers])
	{
		if(vc == [self.navigationController topViewController])
		   [vcs addObject:vc];
	}
    
	[self.navigationController setViewControllers:vcs];
}

- (void) updateButtons
{
	Language language = [Model sharedInstance].settings.language;
	[self.buttonLanguage setTitle:[_modeStrings[SelectionModeLanguage] objectAtIndex:language] forState:UIControlStateNormal];
	
	RequestsFrequency frequency = [Model sharedInstance].settings.requestsFrequency;
	[self.buttonPollingFrequency setTitle:[_modeStrings[SelectionModePollingFrequency] objectAtIndex:frequency] forState:UIControlStateNormal];
	
	ActiveInBackground active = [Model sharedInstance].settings.activeInBackground;
	[self.buttonActiveInBackground setTitle:[_modeStrings[SelectionModeActiveInBackground] objectAtIndex:active] forState:UIControlStateNormal];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(245.0 / 255.0) green:(245.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];

	_modeStrings[SelectionModeLanguage] = @[@"Default", @"Belarusian", @"German", @"English", @"Spanish", @"French", @"Russian", @"Chinese", @"Poland", @"Italian", @"Turkey"];
	
	NSMutableArray* pollingFrequency = [NSMutableArray array];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Set automatically"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Seldom"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Very seldom"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Average"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Often"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Very often"]];	
	_modeStrings[SelectionModePollingFrequency] = [pollingFrequency copy];
	
	NSMutableArray* activeInBackground = [NSMutableArray array];	
	[activeInBackground addObject:[DELEGATE localizedStringForKey:@"Always"]];
	[activeInBackground addObject:[DELEGATE localizedStringForKey:@"30 minutes"]];
	[activeInBackground addObject:[DELEGATE localizedStringForKey:@"An hour/60 minutes"]];
	[activeInBackground addObject:[DELEGATE localizedStringForKey:@"3 hours"]];
	[activeInBackground addObject:[DELEGATE localizedStringForKey:@"12 hours"]];
	_modeStrings[SelectionModeActiveInBackground] = [activeInBackground copy];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Settings"]];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.selectionVC)
	{
		NSUInteger selectedValue = [self.selectionVC.selectedValues firstIndex];
		
		if (_pickerViewMode == SelectionModeLanguage)
        {
            [Model sharedInstance].settings.language = selectedValue;
        }
		if (_pickerViewMode == SelectionModeActiveInBackground)
        {
            [Model sharedInstance].settings.activeInBackground = selectedValue;
        }
		else if (_pickerViewMode == SelectionModePollingFrequency)
        {
            [Model sharedInstance].settings.requestsFrequency = selectedValue;
        }

		self.selectionVC = nil;
	}
    
	[self updateButtons];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onSelectLanguage
{
	_pickerViewMode = SelectionModeLanguage;
	
	NSMethodSignature* methodSig = [[self class] instanceMethodSignatureForSelector:@selector(changeLanguage)];
	NSInvocation* operation = [NSInvocation invocationWithMethodSignature:methodSig];
	operation.target = self;
	operation.selector = @selector(changeLanguage);
	
	self.selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	self.selectionVC.invocation = operation;
	self.selectionVC.title = [DELEGATE localizedStringForKey:@"Language"];
	self.selectionVC.values = _modeStrings[_pickerViewMode];
	self.selectionVC.selectAllValue = -1;
	
	NSUInteger index = [Model sharedInstance].settings.language;
	self.selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:self.selectionVC animated:YES];
}

- (IBAction) onSelectPollingFrequency
{
	_pickerViewMode = SelectionModePollingFrequency;
	
	self.selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	self.selectionVC.title = [DELEGATE localizedStringForKey:@"Polling Server Frequency"];
	self.selectionVC.values = _modeStrings[_pickerViewMode];
	
	NSUInteger index = [Model sharedInstance].settings.requestsFrequency;
	self.selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:self.selectionVC animated:YES];	
}

- (IBAction) onSelectActiveInBackground
{
	_pickerViewMode = SelectionModeActiveInBackground;

	self.selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	self.selectionVC.title = [DELEGATE localizedStringForKey:@"Active In Background"];
	self.selectionVC.values = _modeStrings[_pickerViewMode];
	
	NSUInteger index = [Model sharedInstance].settings.activeInBackground;
	self.selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:self.selectionVC animated:YES];	
}

- (IBAction) onMyGroups
{
	UIViewController* vc = [DELEGATE controllerWithName:@"MyGroupsVC" fromStoryboard:@"GroupStoryboard"];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) viewDidUnload
{
	[self setButtonLanguage:nil];
	[self setButtonPollingFrequency:nil];
	[self setButtonActiveInBackground:nil];
    
	[super viewDidUnload];
}
@end
