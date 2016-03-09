//
//  TKContactsMultiPickerController.m
//  TKContactsMultiPicker
//
//  Created by Jongtae Ahn on 12. 8. 31..
//  Copyright (c) 2012년 TABKO Inc. All rights reserved.
//

#import "ContactsMultiPickerVC.h"
#import "ABContact.h"

@interface ABContact(Sort)

- (NSString*)sorterFirstName;
- (NSString*)sorterLastName;

@end

@implementation ABContact(Sort)

- (NSString*)sorterFirstName
{
    if (nil != self.firstname && ![self.firstname isEqualToString:@""])
        return self.firstname;
		
    if (nil != self.lastname && ![self.lastname isEqualToString:@""])
        return self.lastname;

    if (nil != self.contactName && ![self.contactName isEqualToString:@""])
        return self.contactName;
	
    return nil;
}

- (NSString*)sorterLastName
{
    if (nil != self.lastname && ![self.lastname isEqualToString:@""])
        return self.lastname;

    if (nil != self.firstname && ![self.firstname isEqualToString:@""])
        return self.firstname;

    if (nil != self.contactName && ![self.contactName isEqualToString:@""])
        return self.contactName;

    return nil;
}

@end

@interface Pair : NSObject
{
	ABContact* _contact;
	NSInteger _section;
}

@property(nonatomic, readonly, strong) ABContact* contact;
@property(nonatomic, readonly) NSInteger section;
@property(nonatomic, assign) BOOL isSelected;

+(Pair*)pairWithContact:(ABContact*)contact section:(NSInteger)section;
- (NSString*)sorterFirstName;
- (NSString*)sorterLastName;

@end

@implementation Pair

@synthesize contact = _contact;
@synthesize section = _section;

+(Pair*)pairWithContact:(ABContact*)contact section:(NSInteger)section
{
	Pair* pair = [Pair new];
	pair->_contact = contact;
	pair->_section = section;
	pair.isSelected = NO;
	return pair;
}

- (NSString*)sorterFirstName
{
	return [self.contact sorterFirstName];
}

- (NSString*)sorterLastName
{
	return [self.contact sorterLastName];
}

@end

@interface ContactsMultiPickerVC(PrivateMethod)

- (IBAction)doneAction:(id)sender;
- (IBAction)dismissAction:(id)sender;

@end

@implementation ContactsMultiPickerVC
@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize savedSearchTerm = _savedSearchTerm;
@synthesize savedScopeButtonIndex = _savedScopeButtonIndex;
@synthesize searchWasActive = _searchWasActive;
@synthesize searchBar = _searchBar;

- (void)reloadAddressBook
{	   
    // Sort data
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    
    // Thanks Steph-Fongo!
    SEL sorter = ABPersonGetSortOrdering() == kABPersonSortByFirstName ? NSSelectorFromString(@"sorterFirstName") : NSSelectorFromString(@"sorterLastName");
    
	NSMutableArray* sectionNumbers = [NSMutableArray array];
    for (ABContact *contact in _contacts)
	{
        NSInteger section = [theCollation sectionForObject:contact collationStringSelector:sorter];
		Pair* pair = [Pair pairWithContact:contact section:section];
		[sectionNumbers addObject:pair];
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray* sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i <= highSection; i++)
	{
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
    }
    
	for (Pair* pair in sectionNumbers)
        [(NSMutableArray *)[sectionArrays objectAtIndex:pair.section] addObject:pair];
    
    for (NSMutableArray *sectionArray in sectionArrays)
	{
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray collationStringSelector:sorter];
        [_listContent addObject:sortedSection];
    }
    [self.tableView reloadData];
}

#pragma mark Initialization
- (id)initWithContacts:(NSArray*)contacts
{
    if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
	{
		_contacts = contacts;
        _selectedCount = 0;
        _listContent = [NSMutableArray new];
        _filteredListContent = [NSMutableArray new];
    }
    return self;
}

#pragma mark View lifecycle
- (void)viewDidLoad
{
	[super viewDidLoad];
    [self.navigationBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)]];
    
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
	self.searchDisplayController.searchBar.showsCancelButton = NO;

    [self reloadAddressBook];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return nil;
    }
	else
	{
        return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 0;
    }
	else
	{
        if (title == UITableViewIndexSearch)
		{
            [tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
            return -1;
        }
		else
		{
            return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index-1];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
	}
	else
	{
        return [_listContent count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return nil;
    }
	else
	{
        return [[_listContent objectAtIndex:section] count] ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return 0;
    return [[_listContent objectAtIndex:section] count] ? tableView.sectionHeaderHeight : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filteredListContent count];
    }
	else
	{
        return [[_listContent objectAtIndex:section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCustomCellID = @"TKPeoplePickerControllerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCustomCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCustomCellID];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	Pair* pair = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
        pair = (Pair*)[_filteredListContent objectAtIndex:indexPath.row];
	else
        pair = (Pair*)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ([[pair.contact.contactName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0)
	{
        cell.textLabel.text = pair.contact.contactName;
    }
	else
	{
        cell.textLabel.font = [UIFont italicSystemFontOfSize:cell.textLabel.font.pointSize];
        cell.textLabel.text = @"No Name";
    }
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setFrame:CGRectMake(30.0, 0.0, 28, 28)];
	[button setBackgroundImage:[UIImage imageNamed:@"uncheckBox.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"checkBox.png"] forState:UIControlStateSelected];
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    [button setSelected:pair.isSelected];
    
	cell.accessoryView = button;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		[self tableView:self.searchDisplayController.searchResultsTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	else
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	Pair* pair = nil;
    
	if (tableView == self.searchDisplayController.searchResultsTableView)
		pair = (Pair*)[_filteredListContent objectAtIndex:indexPath.row];
	else
        pair = (Pair*)[[_listContent objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    BOOL checked = !pair.isSelected;
	pair.isSelected = checked;
    
    // Enabled rightButtonItem
    if (checked)
		_selectedCount++;
    else
		_selectedCount--;
	
    if (_selectedCount > 0)
        [self.navigationBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)]];
    else
        [self.navigationBar.topItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissAction:)]];
    
    UITableViewCell *cell =[self.tableView cellForRowAtIndexPath:indexPath];
    UIButton *button = (UIButton *)cell.accessoryView;
    [button setSelected:checked];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	
	if (indexPath != nil)
	{
		[self tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
	}
}

#pragma mark -
#pragma mark Save action

- (IBAction)doneAction:(id)sender
{
	NSMutableArray* objects = [NSMutableArray new];
    for (NSArray* section in _listContent)
	{
        for (Pair* pair in section)
        {
            if (pair.isSelected)
                [objects addObject:pair];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(tkContactsMultiPickerController:didFinishPickingDataWithInfo:)])
	{
		NSMutableArray* contacts = [NSMutableArray arrayWithCapacity:[objects count]];
		for(Pair* pair in objects)
			[contacts addObject:pair.contact];
		
        [self.delegate tkContactsMultiPickerController:self didFinishPickingDataWithInfo:contacts];
	}
}

- (IBAction)dismissAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tkContactsMultiPickerControllerDidCancel:)])
        [self.delegate tkContactsMultiPickerControllerDidCancel:self];
    else
        [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent)
	{
        for (Pair* pair in section)
        {
			//try to find by firstname
            NSComparisonResult result = [pair.contact.firstname compare:searchText
																  options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
																	range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
                [_filteredListContent addObject:pair];
			else //try to find by lastname
			{
				NSComparisonResult result = [pair.contact.lastname compare:searchText
																   options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch)
																	 range:NSMakeRange(0, [searchText length])];
				if (result == NSOrderedSame)
					[_filteredListContent addObject:pair];
			}

        }
    }
}

#pragma mark -
#pragma mark UISearchDisplayControllerDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles]
	  objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

- (void)viewDidUnload {
	[self setNavigationBar:nil];
	[super viewDidUnload];
}
@end