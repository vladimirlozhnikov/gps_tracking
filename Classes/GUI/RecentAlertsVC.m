//
//  RecentAlertsVC.m
//  GPSTracker
//
//  Created by YS on 1/7/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "RecentAlertsVC.h"
#import "Model.h"

@interface RecentAlertsVC()

@property(nonatomic) Settings* settings;

@end

@implementation RecentAlertsVC

- (void) viewDidLoad
{
    [super viewDidLoad];
	UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onEditTable:)];
	[self.table addGestureRecognizer:gesture];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Edit alert templates"]];
    
    // resize table image
    UIImage* selectTableImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeTableImage = [selectTableImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.tableImage.image = resizeTableImage;
    
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
	self.settings = [Model sharedInstance].settings;
	self.buttonAdd.enabled = NO;
	NSIndexPath* indexPath = [self.table indexPathForSelectedRow];
	if (!indexPath)
    {
        return;
    }
	
	[self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) viewDidUnload
{
	[self setTable:nil];
	[self setTextFieldText:nil];
	[self setButtonAdd:nil];
	[self setLabelTitle:nil];
    
	[super viewDidUnload];
}

- (IBAction) onAdd
{
	self.buttonAdd.enabled = NO;
	[self.table beginUpdates];

	[self.settings.alertTemplates addObject:self.textFieldText.text];
    [self.settings save];
	self.textFieldText.text = nil;

	NSUInteger alertTemplatesCount = [self.settings.alertTemplates count];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:alertTemplatesCount - 1 inSection:0];
	[self.table insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.table endUpdates];
}

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) onEditTable:(UILongPressGestureRecognizer*)sender
{
	if (sender.state != UIGestureRecognizerStateBegan)
    {
        return;
    }
	
	[self.table setEditing:![self.table isEditing] animated:YES];
	self.labelTitle.text = self.table.editing ? @"Action" : @"Template Messages";
}

#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[UIView commitAnimations];
	
	[self.table selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	RecentAlertCell* cell = (RecentAlertCell*)[self.table cellForRowAtIndexPath:indexPath];

	if ([cell.textField.text length])
	{
		NSString* strNew = cell.textField.text;
		[self.settings.alertTemplates replaceObjectAtIndex:[indexPath row] withObject:strNew];
	}
	else
	{
		NSString* strOriginal = [self.settings.alertTemplates objectAtIndex:[indexPath row]];
		cell.textField.text = strOriginal;
	}
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (!self.table.tracking && !self.table.decelerating) ? indexPath : nil;
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.settings.alertTemplates count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"RecentAlertCell_%d", index];
	RecentAlertCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
    {
        cell = [[RecentAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

	cell.delegate = self;
	NSString* text = [self.settings.alertTemplates objectAtIndex:[indexPath row]];
	cell.textField.text = text;
    
	return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle != UITableViewCellEditingStyleDelete)
    {
        return;
    }

	[self.table beginUpdates];
	[self.settings.alertTemplates removeObjectAtIndex:[indexPath row]];
	[self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.table endUpdates];
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
{
	[self.table beginUpdates];
	[self.settings.alertTemplates exchangeObjectAtIndex:[sourceIndexPath row] withObjectAtIndex:[destinationIndexPath row]];
	[self.table moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
	[self.table endUpdates];
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	self.buttonAdd.enabled = ([textField.text length] + [string length] - range.length) > 0;
	return YES;
}

#pragma mark RecentAlertCellDelegate
-(void) recentAlertCell:(RecentAlertCell*)cell didChangeText:(NSString*)text
{
	NSUInteger index = [[self.table indexPathForCell:cell] row];
	[self.settings.alertTemplates replaceObjectAtIndex:index withObject:text];
}

@end
