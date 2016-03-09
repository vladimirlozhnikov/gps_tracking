//
//  TrackerTableVC.m
//  GPSTracker
//
//  Created by YS on 2/5/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerTableVC.h"
#import "TrackerCell.h"
#import "DBUser+Methods.h"
#import "DBGroup+Methods.h"
#import "Model.h"

@implementation TrackerTableVC

- (void) viewDidLoad
{
    // resize table image
    UIImage* selectTableImage = [UIImage imageNamed:@"green_border.png"];
    UIImage* resizeTableImage = [selectTableImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.tableImage.image = resizeTableImage;
}

- (void) setDisplayGroupUser:(BOOL)display users:(NSArray*)users
{
	_isDisplayGroupUsers = display;
	self.users = users;
	[self.table reloadData];
}

- (IBAction) onHide
{
	//[self hideAnimated:YES];
}

- (BOOL) isDisplayGroupUsers
{
	return _isDisplayGroupUsers;
}

- (void) setSelectedUser:(DBUser *)selectedUser
{
	_selectedUser = selectedUser;
}

- (DBUser*) selectedUser
{
	return _selectedUser;
}

- (BOOL) isTableVisible
{
	return (self.view.frame.origin.x == 300);
}

- (void) setTableHidden:(BOOL)hidden animated:(BOOL)animated
{
	__block BOOL hiddenValue = hidden;
	self.table.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.75f];
    
	CGRect rc = self.view.frame;
	if (!hiddenValue)
    {
        rc.origin = CGPointMake(7, 90);
    }
	else
    {
        rc.origin = CGPointMake(300, 90);
    }

	if (!animated)
	{
		self.view.frame = rc;

		if (!hiddenValue)
        {
            [self.table reloadData];
        }
		
		return;
	}
		
	[UIView animateWithDuration:animated ? 0.3f : 0.f animations:^()
	{
		self.view.frame = rc;
	}
	completion:^(BOOL finished)
	{
		 if(!hiddenValue)
         {
             [self.table reloadData];
         }
	 }];
}

- (void) hideAnimated:(BOOL)animated
{
	[self setTableHidden:YES animated:animated];
}

- (void) showAnimated:(BOOL)animated
{
	if (!self.isDisplayGroupUsers)
    {
        [self setTableHidden:NO animated:animated];
    }
	else
    {
        [self setTableHidden:![self isTableVisible] animated:animated];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.users count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 4;
	NSString* identifier = [NSString stringWithFormat:@"TrackerCell_%d", index];

	TrackerCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
    {
        cell = [[TrackerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
	
	DBUser* user = [self.users objectAtIndex:[indexPath row]];
	cell.labelUserInfo.text = [NSString stringWithFormat:@"%@ %@ %@", user.nickName, user.firstName, user.lastName];
	cell.labelDistance.text = [self.delegate distanceToUser:user kmHOnly:YES];
    [user imageInBackground:cell.imageView];
    
    if ([user.index isEqualToString:DELEGATE.me.index])
    {
        cell.backgroundImage.image = [UIImage imageNamed:@"cell.png"];
    }
    else
    {
        cell.backgroundImage.image = [UIImage imageNamed:@"cell_green.png"];
    }

	if(user == self.selectedUser)
    {
        [self.table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
	else
    {
        [self.table deselectRowAtIndexPath:indexPath animated:NO];
    }
	
	return cell;
}

#pragma mark UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DBUser* user = [self.users objectAtIndex:[indexPath row]];

	CLLocationCoordinate2D centerCoordinate = user.coordinate;
	MKCoordinateSpan newSpan = MKCoordinateSpanMake(0.01, 0.01);
	MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, newSpan);
	[self setTableHidden:YES animated:YES];
	[self.delegate needZoomToRegion:region forUser:user];
}

- (void) viewDidUnload
{
	[self setTable:nil];
	[super viewDidUnload];
}

@end
