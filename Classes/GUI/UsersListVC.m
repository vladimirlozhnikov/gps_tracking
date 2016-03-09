//
//  UsersListVC.m
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UsersListVC.h"
#import "Model.h"
#import "UsersListCell.h"
#import "DBGroup+Methods.h"

@implementation UsersListVC

- (void) viewDidUnload
{
    [self setTable:nil];
	[self setTextFieldSearchCriteria:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	_filteredUsers = self.group.users;
}

- (void) viewDidLoad
{
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"List of users"]];
    
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

- (IBAction) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_filteredUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"UsersListCell_%d", index];
	UsersListCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
    {
        cell = [[UsersListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
	
	DBUser* user = [_filteredUsers objectAtIndex:[indexPath row]];
	cell.labelText.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    
	return cell;
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	BOOL isFilled = ([textField.text length] + [string length] - range.length) > 0;
	
	if (isFilled)
	{
		NSMutableString* criteria = [NSMutableString stringWithString:textField.text];
		[criteria deleteCharactersInRange:range];
		[criteria appendString:string];
		_filteredUsers = [self.group filterUsersWithCriteria:criteria];
	}
	else
	{
		_filteredUsers = self.group.users;
	}
	[self.table reloadData];
    
	return YES;
}

@end
