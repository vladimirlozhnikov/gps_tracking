//
//  SelectionVC.m
//  GPSTracker
//
//  Created by YS on 1/28/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SelectionVC.h"
#import "SelectionCell.h"
#import "Model.h"

@interface SelectionVC()

@property (nonatomic) BOOL isSelectedAll;

@end

@implementation SelectionVC
@synthesize showAGPS;
@synthesize selectedValues = _selectedValues;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		self.isAnimatedBack = YES;
		self.selectAllValue = -1;
		self.isMultiSelection = NO;
		self.isSelectedAll = NO;
	}
	return self;
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [super viewDidUnload];
}

- (void) viewDidLoad
{
    // resize table image
    UIImage* selectTableImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeTableImage = [selectTableImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.tableImage.image = resizeTableImage;
    
    if (self.showAGPS)
    {
        self.agpsLabel.hidden = NO;
        self.agpsSwitch.hidden = NO;
        self.agpsSwitch.on = [Model sharedInstance].settings.agpsIsOn;
    }
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)viewWillAppear:(BOOL)animated
{
	if (self.selectedValues)
		_selectedValues = [self.selectedValues mutableCopy];
	else
		_selectedValues = [NSMutableIndexSet indexSet];

	[super viewWillAppear:animated];
    [self.navigationItem setTitle:self.title];
	self.table.allowsMultipleSelection = self.isMultiSelection;
	self.isSelectedAll = ([_selectedValues containsIndex:self.selectAllValue]);
	
	if(!self.isMultiSelection && ([self.selectedValues count] == 1))
    {
        NSUInteger ind = [self.selectedValues firstIndex];
		[self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:ind inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)onBack:(id)sender
{
    if(self.selectAllValue != -1)
	{
		[_selectedValues removeIndex:self.selectAllValue];
		
		NSMutableIndexSet* tmp = [NSMutableIndexSet indexSet];
		[_selectedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
		 {
			 [tmp addIndex:idx - 1];
		 }];
		
		self.selectedValues = tmp;
	}
	[self.invocation invoke];
	[self.navigationController popViewControllerAnimated:self.isAnimatedBack];
}

- (IBAction)agpsValueChanged:(id)sender
{
    [Model sharedInstance].settings.agpsIsOn = self.agpsSwitch.on;
}

- (void)processSelectAll
{
	for(NSUInteger i = 0; i < [self.values count]; ++i)
	{
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
		if(self.isSelectedAll)
		{
			[_selectedValues removeIndex:i];
			[self.table deselectRowAtIndexPath:indexPath animated:YES];
			[self.table cellForRowAtIndexPath:indexPath].selected = NO;
		}
		else
		{
			[_selectedValues addIndex:i];
			[self.table selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
			
			[self.table cellForRowAtIndexPath:indexPath].selected = YES;
		}		
	}
	self.isSelectedAll = !self.isSelectedAll;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"SelectionCell_%d", index];
	SelectionCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(!cell)
    {
        cell = [[SelectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
		
	cell.label.text = [self.values objectAtIndex:[indexPath row]];
	if([_selectedValues containsIndex:[indexPath row]] || self.isSelectedAll)
	{
		[_selectedValues addIndex:[indexPath row]];
		[self.table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	else
	{
		[_selectedValues removeIndex:[indexPath row]];
		[self.table deselectRowAtIndexPath:indexPath animated:NO];
	}
	
	return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_selectedValues addIndex:[indexPath row]];
	[self.table cellForRowAtIndexPath:indexPath].selected = YES;

	// process select all
	if(self.selectAllValue == [indexPath row])
    {
        [self processSelectAll];
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_selectedValues removeIndex:[indexPath row]];
	[self.table cellForRowAtIndexPath:indexPath].selected = NO;
	
	//process select all
	if(self.selectAllValue == [indexPath row])
    {
        [self processSelectAll];
    }
	else
	{
		self.isSelectedAll = NO;
		[_selectedValues removeIndex:self.selectAllValue];
		[self.table deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectAllValue inSection:0] animated:YES];
		[self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectAllValue inSection:0]].selected = NO;
	}
}

@end
