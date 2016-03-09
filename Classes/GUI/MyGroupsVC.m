//
//  MyGroupsVC.m
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyGroupsVC.h"
#import "Model.h"
#import "MyGroupCell.h"
#import "MyGroupEditVC.h"
#import "DBGroup+Methods.h"

@implementation MyGroupsVC

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onEditTable:)];
	[self.table addGestureRecognizer:gesture];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Edit my groups"]];
    
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
	[super viewDidUnload];
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
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[Model sharedInstance].myGroups count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"MyGroupCell_%d", index];
	MyGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if(!cell)
    {
        cell = [[MyGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
	
	DBGroup* group = [[Model sharedInstance].myGroups groupAtIndex:[indexPath row]];
	cell.selected = group.isOwner;
	cell.labelText.text = group.name;
	cell.labelAdmin.text = group.isOwner ? @"I'm Admin" : nil;
    
	return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle != UITableViewCellEditingStyleDelete)
    {
        return;
    }
	
	DBGroup* group = [[Model sharedInstance].myGroups groupAtIndex:[indexPath row]];
	if (group.isOwner)
	{
		[self.table beginUpdates];
		[DELEGATE showActivity];
		[[Model sharedInstance].myGroups deleteGroup:group withSuccess:^()
		{
			 [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			 [DELEGATE hideActivity];
			 [self.table endUpdates];
		}
		onError:^(NSString* error)
		{
			[DELEGATE hideActivity];
			[DELEGATE showAlertWithMessage:error];
			[self.table endUpdates];
		}];
	}
	else
	{
		[self.table beginUpdates];
		[[Model sharedInstance].myGroups removeGroupAtIndex:[indexPath row]];
		[self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self.table endUpdates];
	}
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
{
	[self.table beginUpdates];
	[[Model sharedInstance].myGroups exchangePositionFrom:[sourceIndexPath row] to:[destinationIndexPath row]];
	[self.table moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
	[self.table endUpdates];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"Edit Group" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	MyGroupEditVC* vc = (MyGroupEditVC*)segue.destinationViewController;
	NSIndexPath* indexPath = [self.table indexPathForSelectedRow];
	vc.group = [[Model sharedInstance].myGroups groupAtIndex:[indexPath row]];
}

@end
