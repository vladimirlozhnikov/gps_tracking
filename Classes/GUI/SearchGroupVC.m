//
//  SearchGroupVC.m
//  GPSTracker
//
//  Created by YS on 1/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SearchGroupVC.h"
#import "Model.h"
#import "SearchGroupCell.h"
#import "TrackerVC.h"
#import "AdminDetailsVC.h"
#import "UsersListVC.h"
#import "MyGroupEditVC.h"
#import "SelectionVC.h"
#import "JoinGroupVC.h"
#import "TypeUtils.h"
#import "DBGroup+Methods.h"
#import "BaseTableCell.h"
#import "SearchGroupHeader.h"

@interface SearchGroupVC()

@property(nonatomic) BOOL isInited;

@end

@implementation SearchGroupVC

- (void) updateButtons
{
	[self.buttonCountry setTitle:_country.name forState:UIControlStateNormal];
	[self.buttonCity setTitle:_city.name forState:UIControlStateNormal];
	[self.buttonRadius setTitle:[_radiusValues objectAtIndex:_radius] forState:UIControlStateNormal];
}

- (void) updateCitiesWithBlock:(void(^)())block
{
	[[Model sharedInstance].locations citiesByCountry:_country
	onSuccess:^(NSArray* cities)
	{
        [_cities removeAllObjects];
        for (DBCity* c in cities)
        {
            [_cities addObject:c];
        }
        
		block();
	}
	onError:^(NSString *error)
	{
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) onSearch
{
	[DELEGATE showActivity];
	
    if (_country)
    {
        [Model sharedInstance].settings.lastCountryID = [_country.index integerValue];
    }
    if (_city)
    {
        [Model sharedInstance].settings.lastCityID = [_city.index integerValue];
    }
	
	[[Model sharedInstance] searchGroupsWithCountryID:[_country.index integerValue] cityID:[_city.index integerValue]
	withSuccess:^(NSArray* groups)
	{
        [_searchResults removeAllObjects];
        [expandedSections removeAllObjects];
        for (DBGroup* g in groups)
        {
            [_searchResults addObject:g];
            [expandedSections addObject:[NSNumber numberWithBool:NO]];
        }
        
		[DELEGATE hideActivity];
		[self.table reloadData];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    _searchResults = [[NSMutableArray alloc] init];
	self.scrollView.contentSize = CGSizeMake(302, 670);
    self.scrollView.backgroundColor = [UIColor colorWithRed:(245.0 / 255.0) green:(245.0 / 255.0) blue:(245.0 / 255.0) alpha:1.0];
    
    _cities = [[NSMutableArray alloc] init];
    expandedSections = [[NSMutableArray alloc] init];
    
	NSMutableArray* distance = [NSMutableArray array];
	[distance addObject:[DELEGATE localizedStringForKey:@"Within 1 km"]];
	[distance addObject:[DELEGATE localizedStringForKey:@"from 1 to 5 km"]];
	[distance addObject:[DELEGATE localizedStringForKey:@"from 5 to 15 km"]];
	[distance addObject:[DELEGATE localizedStringForKey:@"from 15 to 70 km"]];
	_radiusValues = [distance copy];
    
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Search for groups"]];
    
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

- (void) viewDidUnload
{
    [self setButtonCountry:nil];
    [self setButtonCity:nil];
    [self setButtonRadius:nil];
	[self setTable:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void) initFromLastValues
{
	if (self.isInited)
    {
        [self updateButtons];
		//[self onSearch];
        
		return;
    }
	
	self.isInited = YES;
	[self.buttonCountry setTitle:nil forState:UIControlStateNormal];
	[self.buttonCity setTitle:nil forState:UIControlStateNormal];
	
	NSInteger lastCountryID = [Model sharedInstance].settings.lastCountryID;
	if (lastCountryID == -1)
    {
        _country = [[Model sharedInstance].locations.countries objectAtIndex:0];
    }
	else
    {
        _country = [[Model sharedInstance].locations countryByCountryID:lastCountryID];
    }
	
    if ([_cities count] == 0)
    {
        [DELEGATE showActivity];
        [self updateCitiesWithBlock:^
         {
             [DELEGATE hideActivity];
             NSInteger lastCityID = [Model sharedInstance].settings.lastCityID;
             if (lastCityID == -1)
             {
                 _city = [_cities objectAtIndex:0];
             }
             else
             {
                 _city = [[Model sharedInstance].locations cityByCityID:lastCityID forCountryID:[_country.index integerValue]];
             }
             
             [self updateButtons];
             [self onSearch];
         }];
    }
    else
    {
        [self updateButtons];
        [self onSearch];
    }
}

- (void) updateCountriesWithSelectedIndex:(NSUInteger)selectedIndex
{
	DBCountry* country = [[Model sharedInstance].locations.countries objectAtIndex:selectedIndex];
	if ([_country.index isEqualToString:country.index])
	{
		[self updateButtons];
		[self onSearch];
        
		return;
	}
	
    _country = country;
    [DELEGATE showActivity];
	[self updateCitiesWithBlock:^
	{
        [DELEGATE hideActivity];
		_city = [_cities objectAtIndex:0];
		[self updateButtons];
		[self onSearch];
	}];	
}

- (void) updateCitiesWithSelectedIndex:(NSUInteger)selectedIndex
{
	_city = [_cities objectAtIndex:selectedIndex];
	[self updateButtons];
	[self onSearch];
}

- (void) updateRadiusWithSelectedIndex:(NSUInteger)selectedIndex
{
	_radius = selectedIndex;
	[self updateButtons];
	[self onSearch];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (_selectionVC)
	{
		NSUInteger selectedIndex = [_selectionVC.selectedValues firstIndex];
		
		[self.table reloadData];
		
		switch (_selectionMode)
		{
			case SearchSelectionModeCountry:
				[self updateCountriesWithSelectedIndex:selectedIndex];
				break;
			case SearchSelectionModeCity:
				[self updateCitiesWithSelectedIndex:selectedIndex];
				break;
			case SearchSelectionModeRadius:
				[self updateRadiusWithSelectedIndex:selectedIndex];
				break;
			default:
				break;
		}
        
		_selectionVC = nil;
	}
	else
	{
		[self initFromLastValues];
	}
    
    self.trafficInLabel.text = [[Model sharedInstance].settings friendlyDownloadTraffic];
    self.trafficOutLabel.text = [[Model sharedInstance].settings friendlyUploadTraffic];
}

- (IBAction) onCountry
{
	_selectionMode = SearchSelectionModeCountry;
	
	_selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	_selectionVC.title = [DELEGATE localizedStringForKey:@"Country"];
	
	NSMutableArray* values = [NSMutableArray array];
	for (DBCountry* country in [Model sharedInstance].locations.countries)
    {
        [values addObject:country.name];
    }
	
	_selectionVC.values = values;
	_selectionVC.isMultiSelection = NO;
	NSUInteger index = [[Model sharedInstance].locations indexByCountryID:[_country.index integerValue]];
	_selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:_selectionVC animated:YES];
}

- (IBAction) onCity
{
	_selectionMode = SearchSelectionModeCity;
	
	_selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	_selectionVC.title = [DELEGATE localizedStringForKey:@"City"];
	
	NSMutableArray* values = [NSMutableArray array];
	for (DBCity* city in _cities)
    {
        [values addObject:city.name];
    }
	
	_selectionVC.values = values;
	_selectionVC.isMultiSelection = NO;
	
	NSUInteger index = [[Model sharedInstance].locations indexByCityID:[_city.index integerValue] forCountryID:[_country.index integerValue]];
	if (index != -1)
    {
        _selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
    }
    else
    {
        _selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:0];
    }
	
	[self.navigationController pushViewController:_selectionVC animated:YES];
}

- (IBAction) onRadius
{
	_selectionMode = SearchSelectionModeRadius;
	
	_selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	_selectionVC.title = [DELEGATE localizedStringForKey:@"Radius"];
	_selectionVC.values = _radiusValues;
	_selectionVC.isMultiSelection = NO;
	_selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:_radius];
	[self.navigationController pushViewController:_selectionVC animated:YES];
}

- (IBAction) onClose:(id)sender
{
    [[Model sharedInstance] clear];
    [_cities removeAllObjects];
    [_searchResults removeAllObjects];
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) joinWithText:(NSString*)text group:(DBGroup*)group
{
	[DELEGATE showActivity];
	[group joinWithTicket:text onSuccess:^()
	{
		[group updateUsersWithCriteria:@"" withSuccess:^
		{
			[Model sharedInstance].updateManager.activeGroup = group;
			[DELEGATE.me updatePinIsActive:YES];
			[[Model sharedInstance].updateManager pingIsActive:YES frequency:[Model sharedInstance].settings.requestsFrequency];
			
			[DELEGATE hideActivity];
            [DELEGATE.me addMyGroup:group];
			TrackerVC* vc = (TrackerVC*)[DELEGATE controllerWithName:@"TrackerVC" fromStoryboard:@"TrackerStoryboard"];
			vc.group = group;
			DELEGATE.currentGroup = group;;
			[self.navigationController pushViewController:vc animated:YES];
		}
		onError:^(NSString *error)
		{
			[DELEGATE hideActivity];
			[DELEGATE showAlertWithMessage:error];
		}];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	 }];
}

#pragma mark SearchGroupCellDelegate
-(void) searchGroupCellOnName:(SearchGroupHeader*)cell
{
    NSInteger index = cell.index;
    BOOL expanded = [[expandedSections objectAtIndex:index] boolValue];
    [expandedSections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:!expanded]];
    
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:NO];
    
    if (!expanded)
    {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }
}

-(void) searchGroupCellOnOwner:(SearchGroupCell*)cell
{
	NSInteger index = cell.index;
	DBGroup* group = [_searchResults objectAtIndex:index];
	AdminDetailsVC* vc = (AdminDetailsVC*)[DELEGATE controllerWithName:@"AdminDetailsVC" fromStoryboard:@"GroupStoryboard"];
	vc.user = group.owner;
	[self.navigationController pushViewController:vc animated:YES];
}

-(void) searchGroupCellOnUsers:(SearchGroupCell*)cell
{
	NSInteger index = cell.index;
	DBGroup* group = [_searchResults objectAtIndex:index];
    
    // get users
    [[Model sharedInstance] loadUsers:group withSuccess:^{
        UsersListVC* vc = (UsersListVC*)[DELEGATE controllerWithName:@"UsersListVC" fromStoryboard:@"GroupStoryboard"];
        vc.group = group;
        [self.navigationController pushViewController:vc animated:YES];
    } onError:^(NSString *error) {
        [DELEGATE showAlertWithMessage:error];
    }];
}

-(void) searchGroupCellOnLogin:(SearchGroupCell*)cell
{
    NSInteger index = cell.index;
	DBGroup* group = [_searchResults objectAtIndex:index];
	if ([group.isOpen boolValue])
	{
		[self joinWithText:@"" group:group];
	}
	else
	{
		[self performSegueWithIdentifier:@"Join Group" sender:group];
	}
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"Join Group"])
	{
		JoinGroupVC* vc = (JoinGroupVC*)segue.destinationViewController;
		vc.group = (DBGroup*)sender;
	}
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_searchResults count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SearchGroupHeader* cell = [BaseTableCell cellFromNibNamed:@"SearchGroupHeader" owner:self];
    
    DBGroup* group = [_searchResults objectAtIndex:section];
    
    NSString* name = [NSString stringWithFormat:@"%@ (%d)", group.name, /*[group.users count]*/group.usersCount];
    
    [cell.buttonName setTitle:name forState:UIControlStateNormal];
    cell.cityLabel.text = group.city.name;
    
    NSString* key = [group.isOpen boolValue] ? @"Open" : @"Closed";
	NSString* value = [DELEGATE localizedStringForKey:key];
    cell.labelType.text = value;
    cell.index = section;
    
    cell.delegate = self;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	//return [_searchResults count];
    
    NSNumber* expanded = [expandedSections objectAtIndex:section];
    return [expanded boolValue] ? 1 : 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchGroupCell* cell = (SearchGroupCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchGroupCell"];
    if (cell == nil)
    {
        cell = [BaseTableCell cellFromNibNamed:@"SearchGroupCell" owner:self];
    }
    
    DBGroup* group = [_searchResults objectAtIndex:[indexPath section]];
	
	[cell.buttonOwner setTitle:[DELEGATE localizedStringForKey:@"Owner"] forState:UIControlStateNormal];
    
    NSString* membersText = [NSString stringWithFormat:@"%@ (%d)", [DELEGATE localizedStringForKey:@"Members"], /*[group.users count]*/group.usersCount];
    [cell.buttonUsers setTitle:membersText forState:UIControlStateNormal];
    [cell.buttonLogin setTitle:[DELEGATE localizedStringForKey:@"Log in"] forState:UIControlStateNormal];
    
    cell.index = [indexPath section];
    cell.delegate = self;
    
	return cell;
}

#pragma mark - TrafficProtocol

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload
{
    self.trafficInLabel.text = friendlyDownload;
    self.trafficOutLabel.text = friendlyUpload;
}

@end
