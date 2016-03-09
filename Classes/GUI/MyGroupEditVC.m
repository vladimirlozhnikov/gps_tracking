//
//  MyGroupEditVC.m
//  GPSTracker
//
//  Created by YS on 1/8/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MyGroupEditVC.h"
#import "Model.h"
#import <QuartzCore/QuartzCore.h>
#import "SelectionVC.h"
#import "DBGroup+Methods.h"
#import "DBColor+Methods.h"
#import "ImageUtils.h"
#import "DBUser+Methods.h"
#import "TypeUtils.h"
#import "TrackerVC.h"
#import "JoinGroupVC.h"
#import "ABContactsHelper.h"
#import "AddressBookGroupCell.h"

@implementation MyGroupEditVC

- (id) initWithCoder:(NSCoder *)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		_isInitited = NO;
	}
    
	return self;
}

- (void) dealloc
{
	_selectionVC = nil;
	_country = nil;
	_cities = nil;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _cities = [[NSMutableArray alloc] init];
    
	[self.scrollView setContentSize:CGSizeMake(320, 1200)];
	self.scrollView.backgroundColor = [UIColor whiteColor];
	
	_colors[0] = [UIColor colorWithRed:255.f/255 green:0 blue:0 alpha:1];
	_colors[1] = [UIColor colorWithRed:242.f/255 green:73.f/255 blue:65.f/255 alpha:1];
	_colors[2] = [UIColor colorWithRed:247.f/255 green:109.f/255 blue:106.f/255 alpha:1];
	_colors[3] = [UIColor colorWithRed:245.f/255 green:106.f/255 blue:63.f/255 alpha:1];
	_colors[4] = [UIColor colorWithRed:253.f/255 green:169.f/255 blue:97.f/255 alpha:1];
	_colors[5] = [UIColor colorWithRed:255.f/255 green:243.f/255 blue:35.f/255 alpha:1];
	_colors[6] = [UIColor colorWithRed:255.f/255 green:245.f/255 blue:105.f/255 alpha:1];
	_colors[7] = [UIColor colorWithRed:0 green:75.f/255 blue:6.f/255 alpha:1];
	_colors[8] = [UIColor colorWithRed:68.f/255 green:115.f/255 blue:38.f/255 alpha:1];
	_colors[9] = [UIColor colorWithRed:68.f/255 green:183.f/255 blue:88.f/255 alpha:1];
	_colors[10] = [UIColor colorWithRed:72.f/255 green:186.f/255 blue:124.f/255 alpha:1];
	_colors[11] = [UIColor colorWithRed:20.f/255 green:20.f/255 blue:72.f/255 alpha:1];
	_colors[12] = [UIColor colorWithRed:0 green:69.f/255 blue:94.f/255 alpha:1];
	_colors[13] = [UIColor colorWithRed:61.f/255 green:103.f/255 blue:176.f/255 alpha:1];
	_colors[14] = [UIColor colorWithRed:0 green:178.f/255 blue:155.f/255 alpha:1];
	_colors[15] = [UIColor colorWithRed:104.f/255 green:206.f/255 blue:248.f/255 alpha:1];
	_colors[16] = [UIColor colorWithRed:62.f/255 green:23.f/255 blue:70.f/255 alpha:1];
	_colors[17] = [UIColor colorWithRed:115.f/255 green:24.f/255 blue:63.f/255 alpha:1];
	_colors[18] = [UIColor colorWithRed:146.f/255 green:42.f/255 blue:55.f/255 alpha:1];
	_colors[19] = [UIColor colorWithRed:151.f/255 green:50.f/255 blue:95.f/255 alpha:1];
	_colors[20] = [UIColor colorWithRed:166.f/255 green:113.f/255 blue:177.f/255 alpha:1];
	_colors[21] = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
	_colors[22] = [UIColor colorWithRed:70.f/255 green:70.f/255 blue:70.f/255 alpha:1];
	_colors[23] = [UIColor colorWithRed:149.f/255 green:149.f/255 blue:149.f/255 alpha:1];
	_colors[24] = [UIColor colorWithRed:255.f/255 green:255.f/255 blue:255.f/255 alpha:1];
	_colors[25] = [UIColor colorWithRed:76.f/255 green:49.f/255 blue:26.f/255 alpha:1];
	_colors[26] = [UIColor colorWithRed:152.f/255 green:109.f/255 blue:73.f/255 alpha:1];
	_colors[27] = [UIColor colorWithRed:109.f/255 green:18.f/255 blue:23.f/255 alpha:1];
    
    [self.table setEditing:YES];
    [self.textFieldCustomCity addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.navigationItem setTitle:[DELEGATE localizedStringForKey:@"Add/edit group"]];
    
    // resize description background
    UIImage* selectDescriptionImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeSelectDescriptionImage = [selectDescriptionImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.descriptionImage.image = resizeSelectDescriptionImage;
    
    // resize contacts image
    UIImage* selectContactsImage = [UIImage imageNamed:@"cell.png"];
    UIImage* resizeContactsImage = [selectContactsImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.contactsImage.image = resizeContactsImage;
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    if (self.group)
    {
        // login button
        NSString* loginText = [DELEGATE localizedStringForKey:@"Log in"];
        CGSize loginSize = [loginText sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0]];
        
        UIImage* normalLoginImage = [UIImage imageNamed:@"done_button.png"];
        UIImage* highlightedLoginImage = [UIImage imageNamed:@"done_button_press.png"];
        UIImage* resizeNormalLoginImage = [normalLoginImage stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
        UIImage* resizeHighlightedLoginImage = [highlightedLoginImage stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0];
        
        UIButton* loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, loginSize.width + 10.0, 35.0)];
        loginButton.backgroundColor = [UIColor clearColor];
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, loginSize.width , 35.0)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = loginText;
        [loginButton addSubview:titleLabel];
        [loginButton setBackgroundImage:resizeNormalLoginImage forState:UIControlStateNormal];
        [loginButton setBackgroundImage:resizeHighlightedLoginImage forState:UIControlStateHighlighted];
        
        [loginButton addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:loginButton];
        [self.navigationItem setRightBarButtonItem:rightItem];
    }
}

- (void) updateCitiesWithBlock:(void(^)())block
{
	[[Model sharedInstance].locations citiesByCountry:_country
	onSuccess:^(NSArray* cities)
	{
        [_cities removeAllObjects];
        for (DBCity * city in cities)
        {
            if ([city.index integerValue] > 0)
            {
                [_cities addObject:city];
            }
        }
		//_cities = cities;
		[self.buttonCity setTitle:_city.name forState:UIControlStateNormal];
		block();
	}
	onError:^(NSString *error)
	{
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) updateButtons
{
	[self.buttonCountry setTitle:_country.name forState:UIControlStateNormal];
	[self.buttonCity setTitle:_city.name forState:UIControlStateNormal];
	self.buttonCreate.enabled = [self isDataReadyWithExclusion:nil];
}

- (void) fillWithGroup
{
	if (!self.group)
    {
        return;
    }
	
	self.textFieldName.text = self.group.name;
	self.textFieldEmail.text = self.group.email;
	self.textFieldFirstName.text = self.group.firstName;
	self.textFieldLastName.text = self.group.lastName;
	self.textFieldNickName.text = self.group.nickname;
		
	self.imageTickOpen.hidden = ![self.group.isOpen boolValue];
	self.imageTickClosed.hidden = [self.group.isOpen boolValue];
	self.textViewDescription.text = self.group.desc;
		
	[self updateButtons];
	[self updateCitiesWithBlock:^{}];
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (_selectionVC)
	{
		NSUInteger selectedIndex = [_selectionVC.selectedValues firstIndex];
		if (_selectionMode == MyGroupEditModeCountry)
		{
			DBCountry* country = [[Model sharedInstance].locations.countries objectAtIndex:selectedIndex];
			if (![country.index isEqualToString:_country.index])
			{
				_country = country;
				[self updateCitiesWithBlock:^
				{
					_city = [_cities objectAtIndex:0];
					[self updateButtons];
				}];
			}
		}
		else if (_selectionMode == MyGroupEditModeCity)
		{
			_city = [_cities objectAtIndex:selectedIndex];
		}
		
		[self updateButtons];
		_selectionVC = nil;
	}
	else if (self.group)
	{
        NSLog(@"%@", self.group);
        
		self.buttonCreate.hidden = YES;
		self.buttonUpdate.hidden = NO;
		self.imageTickOpen.hidden = ![self.group.isOpen boolValue];
		self.imageTickClosed.hidden = [self.group.isOpen boolValue];
		self.textFieldEntryTicket.enabled = ![self.group.isOpen boolValue];
		
		_country = self.group.country;
		_city = self.group.city;
        
		self.textViewDescription.text = self.group.desc;
		self.textFieldEmail.text = self.group.owner.email;
		self.textFieldFirstName.text = self.group.firstName;
		self.textFieldLastName.text = self.group.lastName;
		self.textFieldNickName.text = self.group.owner.nickName;
        self.textFieldName.text = self.group.name;
		[self updateButtons];
        
        if (!self.group.isOwner)
        {
            self.buttonCreate.enabled = NO;
            self.buttonUpdate.enabled = NO;
            self.textFieldEntryTicket.enabled = NO;
            self.textViewDescription.editable = NO;
            self.textFieldEmail.enabled = NO;
            self.textFieldFirstName.enabled = NO;
            self.textFieldLastName.enabled = NO;
            self.textFieldNickName.enabled = NO;
            self.textFieldName.enabled = NO;
            self.textFieldCustomCity.enabled = NO;
            self.buttonCountry.enabled = NO;
            self.buttonCity.enabled = NO;
            self.addManuallyButton.enabled = NO;
        }
	}
	else if(!_isInitited)
	{
		self.buttonCreate.hidden = NO;
		self.buttonUpdate.hidden = YES;
		self.imageTickOpen.hidden = NO;
		self.imageTickClosed.hidden = YES;
		self.textFieldEntryTicket.enabled = NO;
		
		_country = [Model sharedInstance].locations.locationCountry;
		if (!_country)
		{
			NSInteger countryID = [Model sharedInstance].settings.lastCountryID;
			_country = [[Model sharedInstance].locations countryByCountryID:countryID];
		}
		
		_city = [Model sharedInstance].locations.locationCity;
		if (!_city)
		{
			NSInteger cityID = [Model sharedInstance].settings.lastCityID;
            _city = [[Model sharedInstance].locations cityByCityID:cityID forCountryID:[_country.index integerValue]];
		}
        
		self.textViewDescription.text = nil;
		self.textFieldEmail.text = DELEGATE.me.email;
		self.textFieldFirstName.text = DELEGATE.me.firstName;
		self.textFieldLastName.text = DELEGATE.me.lastName;
        self.textFieldName.text = DELEGATE.me.firstName;
		self.textFieldNickName.text = DELEGATE.me.nickName;
		[self updateButtons];
		[self updateCitiesWithBlock:^{}];
		_isInitited = YES;
	}
    
    // get contacts from address book
    NSArray* groups = [ABContactsHelper groups];
    NSMutableArray* selectedGroups = [NSMutableArray array];
    NSMutableString* groupsString = [NSMutableString string];
    [_selectionVC.selectedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop)
     {
         ABGroup* group = [groups objectAtIndex:idx];
         [groupsString appendFormat:@"%@ ", group.name];
         [selectedGroups addObject:group];
     }];
    
    NSMutableArray* selectedGroupsMembers = [NSMutableArray array];
    for (ABGroup* group in selectedGroups)
    {
        [selectedGroupsMembers addObjectsFromArray:group.members];
    }
    
    NSArray* notAddedContacts = [self notAddedContacts:selectedGroupsMembers];
    _selectionVC = nil;
    if (!_contacts)
    {
        _contacts = [NSMutableArray array];
    }
    
    [_contacts addObjectsFromArray:notAddedContacts];
    [self.table reloadData];
    
	[self fillWithGroup];
}

- (void) viewDidUnload
{
	[self setTextFieldName:nil];
	[self setScrollView:nil];
	[self setButtonCreate:nil];
	[self setTextFieldEmail:nil];
	[self setTextFieldFirstName:nil];
	[self setTextFieldLastName:nil];
	[self setTextFieldNickName:nil];
	[self setTextViewDescription:nil];
	[self setTextFieldEntryTicket:nil];
	[self setTextFields:nil];
	[self setButtonCountry:nil];
	[self setButtonCity:nil];
	[self setTextFieldCustomCity:nil];
    [self setImageTickOpen:nil];
    [self setImageTickClosed:nil];
	[self setButtonUpdate:nil];
    
	[super viewDidUnload];
}

- (BOOL) isDataReadyWithExclusion:(UITextField*)textField
{
	/*NSUInteger filledTextBoxes = textField ? 1 : 0;
	for (UITextField* textFieldCollection in self.textFields)
	{
		if (textField)
        {
            continue;
        }
		
		if ([textFieldCollection.text length])
        {
            ++filledTextBoxes;
        }
	}
	
	BOOL bInvitationFilled = [self.textFieldEntryTicket.text length];
	BOOL isFilledTextBoxes = (filledTextBoxes == 4);
	return (isFilledTextBoxes && (!self.imageTickOpen.hidden || bInvitationFilled) && ([[_city index] integerValue] > 0));*/
    
    /*if (textField != self.textFieldEmail)
    {
        if ([self.textFieldEmail.text length] == 0)
            return NO;
    }
    
    if (textField != self.textFieldFirstName)
    {
        if ([self.textFieldFirstName.text length] == 0)
            return NO;
    }
    
    if (textField != self.textFieldLastName)
    {
        if ([self.textFieldLastName.text length] == 0)
            return NO;
    }
    
    if (textField != self.textFieldNickName)
    {
        if ([self.textFieldNickName.text length] == 0)
            return NO;
    }*/
    
    if (textField != self.textFieldName)
    {
        if ([self.textFieldName.text length] == 0)
            return NO;
    }
    
    if ([[_city index] integerValue] <= 0)
    {
        if (textField != self.textFieldCustomCity)
        {
            if ([self.textFieldCustomCity.text length] == 0)
                return NO;
        }
    }
    
    if ([self.textViewDescription.text length] == 0)
        return NO;
    
    if (self.imageTickOpen.hidden)
    {
        // closed group
        if (textField != self.textFieldEntryTicket)
        {
            if ([self.textFieldEntryTicket.text length] == 0)
                return NO;
        }
    }
    
    return YES;
}

- (IBAction) onCreate
{
	[DELEGATE showActivity];
    
    DBCity* c = _city;
    if ([self.textFieldCustomCity.text length] > 0)
    {
        c = [DBCity cityWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:self.textFieldCustomCity.text, @"name", @"-1", @"city_id", nil]];
    }

	DBGroup* group = [DBGroup groupWithName:self.textFieldName.text description:self.textViewDescription.text country:_country city:c owner:DELEGATE.me isOpen:!self.imageTickOpen.hidden color:[UIColor whiteColor]];
    
	//group.firstName = self.textFieldFirstName.text;
	//group.lastName = self.textFieldLastName.text;
	//group.nickname = self.textFieldNickName.text;
	//group.email = self.textFieldEmail.text;
    group.owner = DELEGATE.me;
    group.name = self.textFieldName.text;
    //group.lastName = self.textFieldLastName.text;
    group.ticket = self.textFieldEntryTicket.text;
    
    NSMutableArray* contacts = [NSMutableArray array];
    for (ABContact* contact in _contacts)
    {
        if (![contact.emailArray count])
            continue;
        
        NSString* email = [contact.emailArray objectAtIndex:0];
        [contacts addObject:email];
    }
	
	[[Model sharedInstance].myGroups createGroup:group withContacts:contacts onSuccess:^
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithBlock:^(NSUInteger clickedButton)
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
         
		message:@"Group create successfully" buttons:@"OK", nil];
	}
	onError:^(NSString *error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (IBAction) onUpdate
{
    //CGFloat red = 1.0;
    //CGFloat green = 1.0;
    //CGFloat blue = 1.0;
    
	self.group.name = self.textFieldName.text;
	self.group.desc = self.textViewDescription.text;
	self.group.country = _country;
	self.group.city = _city;
	self.group.isOpen = [NSNumber numberWithBool:!self.imageTickOpen.hidden];
    //self.group.color.red = [NSNumber numberWithFloat:red];
    //self.group.color.green = [NSNumber numberWithFloat:green];
    //self.group.color.blue = [NSNumber numberWithFloat:blue];
	//self.group.firstName = self.textFieldFirstName.text;
	//self.group.lastName = self.textFieldLastName.text;
	//self.group.nickname = self.textFieldNickName.text;
	//self.group.email = self.textFieldEmail.text;
	//self.group.imageFlag = nil;
    self.group.ticket = self.textFieldEntryTicket.text;

	[DELEGATE showActivity];
	[self.group updateWithSuccess:^
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithBlock:^(NSUInteger clickedButton)
		{
			[self.navigationController popViewControllerAnimated:YES];
		}
         
		message:@"Group updated successfully" buttons:@"OK", nil];
	}
	onError:^(NSString *error)
	{
		[DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
	}];
}

- (void) joinWithText:(NSString*)text group:(DBGroup*)group
{
	[DELEGATE showActivity];
	[self.group joinWithTicket:text onSuccess:^()
     {
         [self.group updateUsersWithCriteria:@"" withSuccess:^
          {
              [Model sharedInstance].updateManager.activeGroup = group;
              [DELEGATE.me updatePinIsActive:YES];
              [[Model sharedInstance].updateManager pingIsActive:YES frequency:[Model sharedInstance].settings.requestsFrequency];
              
              [DELEGATE hideActivity];
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

- (IBAction) onCountry
{
	_selectionMode = MyGroupEditModeCountry;
	
	_selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	_selectionVC.title = [DELEGATE localizedStringForKey:@"Country"];
	
	NSMutableArray* values = [NSMutableArray array];
	for(DBCountry* country in [Model sharedInstance].locations.countries)
		[values addObject:country.name];
	
	_selectionVC.values = values;
	_selectionVC.isMultiSelection = NO;
	NSInteger index = [[Model sharedInstance].locations indexByCountryID:[_country.index integerValue]];
	_selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:_selectionVC animated:YES];
}

- (IBAction) onCity
{
	_selectionMode = MyGroupEditModeCity;
	
	_selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	_selectionVC.title = [DELEGATE localizedStringForKey:@"City"];
	
	NSMutableArray* values = [NSMutableArray array];
	for (DBCity* city in _cities)
    {
        [values addObject:city.name];
    }
	
	_selectionVC.values = values;
	_selectionVC.isMultiSelection = NO;
	NSInteger index = [[Model sharedInstance].locations indexByCityID:[_city.index integerValue] forCountryID:[_country.index integerValue]];
    index = index < 0 ? 0 : index;
	_selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:_selectionVC animated:YES];
}

- (IBAction) onGroupOpen
{
	self.imageTickClosed.hidden = YES;
	self.imageTickOpen.hidden = NO;
	self.textFieldEntryTicket.enabled = NO;
	[self updateButtons];
}

- (IBAction) onGroupClosed
{
	self.imageTickOpen.hidden = YES;
	self.imageTickClosed.hidden = NO;
	self.textFieldEntryTicket.enabled = YES;
	[self updateButtons];
}

- (void) onClose:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) loginClicked:(id) sender
{
    if ([self.group.isOpen boolValue])
	{
		[self joinWithText:@"" group:self.group];
	}
	else
	{
        JoinGroupVC* vc = (JoinGroupVC*)[DELEGATE controllerWithName:@"JoinGroupVC" fromStoryboard:@"GroupStoryboard"];
        vc.group = self.group;
        [self.navigationController pushViewController:vc animated:YES];
	}
}

- (IBAction) onAddManually
{
    [ABContactsHelper contacts:self];
}

- (NSArray*) notAddedContacts:(NSArray*)allContacts
{
	NSMutableArray* notAddedContacts = [NSMutableArray array];
	for (ABContact* contact in allContacts)
	{
		if (![_contacts containsObject:contact])
			[notAddedContacts addObject:contact];
	}
    
	return notAddedContacts;
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	/*if (![self.textFields containsObject:textField])
    {
        return YES;
    }*/
	
	BOOL bFirstFilled = ([textField.text length] + [string length] - range.length) > 0;
	BOOL bDataReady = [self isDataReadyWithExclusion:textField];
	self.buttonCreate.enabled = bFirstFilled && bDataReady;
    
	return YES;
}

- (void) textFieldDidChange:(id)sender
{
    BOOL hidden = ([self.textFieldCustomCity.text length] > 0);
    self.cityLabel.hidden = hidden;
    self.cityArrow.hidden = hidden;
    self.buttonCity.hidden = hidden;
}

#pragma mark UITextViewDelegate
- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
	{
        [textView resignFirstResponder];
		[self updateButtons];
        return NO;
    }
    
	[self updateButtons];
    return YES;
}

#pragma mark - AddressBookProtocol

- (void) didGetContacts:(NSArray *)contacts
{
    NSArray* notAddedContacts = [self notAddedContacts:contacts];
	ContactsMultiPickerVC* vc = [[ContactsMultiPickerVC alloc] initWithContacts:notAddedContacts];
	vc.delegate = self;
	vc.modalPresentationStyle = UIModalPresentationFullScreen;
	[self presentViewController:vc animated:YES completion:nil];
}

#pragma mark TKPeoplePickerControllerDelegate
- (void) tkContactsMultiPickerController:(ContactsMultiPickerVC*)picker didFinishPickingDataWithInfo:(NSArray*)contacts
{
	if (!_contacts)
    {
        _contacts = [NSMutableArray array];
    }
	
	[_contacts addObjectsFromArray:contacts];
	[self.table reloadData];
	[self dismissModalViewControllerAnimated:YES];
	[self updateButtons];
}

- (void) tkContactsMultiPickerControllerDidCancel:(ContactsMultiPickerVC*)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_contacts count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger index = 1 + [indexPath row] % 3;
	NSString* identifier = [NSString stringWithFormat:@"AddressBookGroupCell_%d", index];
	AddressBookGroupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
	if (!cell)
    {
        cell = [[AddressBookGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
	ABContact* contact = [_contacts objectAtIndex:[indexPath row]];
	cell.labelName.text = [contact contactName];
    
	return cell;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
	if (editingStyle != UITableViewCellEditingStyleDelete)
    {
        return;
    }
	
	[self.table beginUpdates];
	[_contacts removeObjectAtIndex:[indexPath row]];
	[self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self.table endUpdates];
	[self updateButtons];
}

@end
