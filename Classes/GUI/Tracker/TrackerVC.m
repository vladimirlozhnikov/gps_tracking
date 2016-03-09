//
//  GroupDetailsVC.m
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "TrackerVC.h"
#import "Model.h"
#import "TrackerClusterAnnotationView.h"
#import "TrackerClusterAnnotation.h"
#import "TrackerUserAnnotationView.h"
#import "WildcardGestureRecognizer.h"
#import "TrackerCell.h"
#import "AlertMessageVC.h"
#import "TrackerUserVC.h"
#import "TrackerMeAnnotationView.h"
#import "Types.h"
#import "UpdatesManager.h"
#import "SelectionVC.h"
#import "DBGroup+Methods.h"
#import "DBUser+Methods.h"
#import "PPDbManager.h"
#import "UserStatisticsVC.h"
#import "TrackerRouteAnnotationView.h"
#import "Pin.h"
#import "TypeUtils.h"
#import "MarkerMenuVC.h"
#import <objc/runtime.h>
#import <FacebookSDK/FacebookSDK.h>
#import "APIKey.h"
#import "ActionSheetPicker.h"
#import "ReadMessageListVC.h"

#define BASE_RADIUS .5 // = 1 mile
#define MINIMUM_LATITUDE_DELTA 0.20
#define BLOCKS 4

#define MINIMUM_ZOOM_LEVEL 100000


@interface TrackerVC()

@property(nonatomic, weak) SelectionVC* selectionVC;

@end

@implementation TrackerVC

- (id) initWithCoder:(NSCoder*)aDecoder
{
	if( self = [super initWithCoder:aDecoder])
	{
		_tableVC = (TrackerTableVC*)[DELEGATE controllerWithName:@"TrackerTableVC" fromStoryboard:@"TrackerStoryboard"];
		_tableVC.delegate = self;
        
		[self addChildViewController:_tableVC];
	}
    
	return self;
}

- (NSString*) distanceToUser:(DBUser*)user kmHOnly:(BOOL)kmHOnly
{
    return [user distanceFromLocation:locationManager.location kmHOnly:kmHOnly];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateDistance
{
	DBUser* user = _selectedUser;
	NSString* distanceString = nil;
    
	if (user && ![user isEqual:DELEGATE.me])
	{
		NSString* distance = [self distanceToUser:user kmHOnly:NO];
		distanceString = [NSString stringWithFormat:@"Distance: %@", distance];
		self.labelDistanceTo.hidden = NO;
		self.imageArrow.hidden = NO;
	}
	else
	{
		self.labelDistanceTo.hidden = YES;
		self.imageArrow.hidden = YES;
	}
    
	self.labelDistanceTo.text = distanceString;
}

- (void) captureUser:(DBUser*)user
{
	[_tableVC setSelectedUser:user];
	_selectedUser = user;
    
    if (user)
    {
        [self.googleMapView animateToLocation:user.coordinate];
        
        for (GMSMarker* marker in markers)
        {
            if ([((DBUser*)[marker userData]).index isEqualToString:user.index])
            {
                //!!! memory leak
                self.googleMapView.selectedMarker = marker;
                break;
            }
        }
        
        if ([user.index isEqualToString:DELEGATE.me.index])
        {
            //!!! memory leak
            self.googleMapView.selectedMarker = marker_me;
        }
    }
    else
    {
        self.googleMapView.selectedMarker = nil;
    }
    
    [self updateDistance];
}

- (void) displayPopoverForFlag:(GMSMarker*)marker
{
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
	//display menu
	MarkerMenuVC* vc = (MarkerMenuVC*)[DELEGATE controllerWithName:@"MarkerMenuVC" fromStoryboard:@"TrackerStoryboard"];
	vc.marker = marker;
	vc.delegate = self;
	
	CGRect rc = CGRectMake(self.view.center.x, self.view.center.y - vc.view.bounds.size.height / 2, 1, 1);
	_popover = [[WEPopoverController alloc] initWithContentViewController:vc];
	WEPopoverContainerViewProperties* props = [WEPopoverContainerViewProperties new];
	props.bgImageName = props.upArrowImageName = props.downArrowImageName =
	props.leftArrowImageName = props.rightArrowImageName = nil;
	_popover.containerViewProperties = props;
	_popover.delegate = self;
	_popover.popoverContentSize = vc.view.bounds.size;
	[_popover presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) displayPopoverForUser:(DBUser*)user
{
	[_popover dismissPopoverAnimated:YES];
	_popover = nil;
		
	//display menu
	UserMapMenuVC* vc = (UserMapMenuVC*)[DELEGATE controllerWithName:@"UserMapMenuVC" fromStoryboard:@"TrackerStoryboard"];
	vc.user = user;
	vc.delegate = self;
	
	CGRect rc = CGRectMake(self.view.center.x, self.view.center.y - vc.view.bounds.size.height / 2, 1, 1);
	_popover = [[WEPopoverController alloc] initWithContentViewController:vc];
	WEPopoverContainerViewProperties* props = [WEPopoverContainerViewProperties new];
	props.bgImageName = props.upArrowImageName = props.downArrowImageName =
	props.leftArrowImageName = props.rightArrowImageName = nil;
	_popover.containerViewProperties = props;
	_popover.delegate = self;
	_popover.popoverContentSize = vc.view.bounds.size;
	[_popover presentPopoverFromRect:rc inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) viewDidLoad
{
	[super viewDidLoad];
    
	[self.view addSubview:_tableVC.view];
	[self.view bringSubviewToFront:self.buttonUsers];
    
    route = [[NSMutableArray alloc] init];
    markers = [[NSMutableArray alloc] init];
    route_me = [[NSMutableArray alloc] init];
    flags = [[NSMutableArray alloc] init];
    addresses = [[NSMutableArray alloc] init];
    
    if ([Model sharedInstance].settings.agpsIsOn)
    {
        self.towerButton.selected = YES;
        self.satelliteButton.selected = NO;
    }
    else
    {
        self.towerButton.selected = NO;
        self.satelliteButton.selected = YES;
    }
    
    self.googleMapView.trafficEnabled = YES;
    self.googleMapView.delegate = self;
    self.googleMapView.settings.rotateGestures = NO;
    self.googleMapView.frame = self.view.bounds;
    [self.googleMapView animateToZoom:12.0];
    
    marker_me = [GMSMarker markerWithPosition:DELEGATE.me.coordinate];
    marker_me.title = [DELEGATE localizedStringForKey:@"You"];
    marker_me.userData = DELEGATE.me;
    marker_me.icon = [DELEGATE.me imageInMarker];
    marker_me.map = self.googleMapView;
     
    [self captureUser:DELEGATE.me];
    
    // center search text field
    UIImageView* searchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 5.0, 150.0, 38.0)];
    searchImage.tag = 665;
    searchImage.hidden = YES;
    searchImage.image = [UIImage imageNamed:@"search_field.png"];
    searchImage.userInteractionEnabled = YES;
    searchImage.multipleTouchEnabled = YES;
    
    UITextField* searchField = [[UITextField alloc] initWithFrame:CGRectMake(15.0, 8.0, 140.0, 25.0)];
    searchField.tag = 666;
    searchField.hidden = YES;
    searchField.enabled = NO;
    searchField.multipleTouchEnabled = YES;
    searchField.userInteractionEnabled = YES;
    searchField.delegate = self;
    searchField.backgroundColor = [UIColor clearColor];
    searchField.textColor = [UIColor colorWithRed:(112.0 / 255.0) green:(112.0 / 255.0) blue:(112.0 / 255.0) alpha:1.0];
    
    [searchImage addSubview:searchField];
    [self.navigationItem setTitleView:searchImage];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onLeave:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    // refresh button
    UIButton* refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39.0, 34.0)];
    [refreshButton setImage:[UIImage imageNamed:@"refrash_icon.png"] forState:UIControlStateNormal];
    [refreshButton setImage:[UIImage imageNamed:@"refrash_icon_press.png"] forState:UIControlStateHighlighted];
    
    [refreshButton addTarget:self action:@selector(refreshClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.distanceFilter = 200;
	locationManager.purpose = @"We goona track your location for display it to other users in the group";
    
    if (![CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        self.satelliteButton.hidden = YES;
        self.towerButton.hidden = YES;
        [Model sharedInstance].settings.agpsIsOn = NO;
    }
    
    if ([Model sharedInstance].settings.agpsIsOn)
    {
        //NSLog(@"startMonitoringSignificantLocationChanges");
        [locationManager startMonitoringSignificantLocationChanges];
    }
    else
    {
        //NSLog(@"startMonitoringSignificantLocationChanges");
        [locationManager startUpdatingLocation];
    }
    
    if ([locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)])
    {
        locationManager.pausesLocationUpdatesAutomatically = NO;
    }
    
    [self prepareData];
}

- (void) viewDidUnload
{
	[self setLabelDistanceTo:nil];
	[self setImageArrow:nil];
	_tableVC = nil;
    [self setLabelMessagesCount:nil];
	[self setButtonUsers:nil];
    [super viewDidUnload];
}

- (void) prepareData
{
	_users = self.group.users;
	_filteredUsers = _users;
    
    for (DBUser* u in _users)
    {
        u.delegate = self;
        [u imageInBackground:nil];
    }

	_tableVC.group = self.group;
	[_tableVC setDisplayGroupUser:YES users:_filteredUsers];
    
    [self redrawMap];
}

- (void) updateUsersWithLeftUsers:(NSArray*)leftUsers joinedUsers:(NSArray*)joinedUsers
{
	_users = self.group.users;
	_filteredUsers = _users;
	
	if(![_users containsObject:_selectedUser])
    {
        [self captureUser:nil];
    }
	
	[_tableVC setDisplayGroupUser:YES users:_filteredUsers];
    
    for (DBUser* u in leftUsers)
    {
        u.delegate = nil;
        
        for (GMSMarker* marker in markers)
        {
            if ([[(DBUser*)[marker userData] index] isEqualToString:u.index])
            {
                marker.map = nil;
                [markers removeObject:marker];
                break;
            }
        }
    }
    
    for (DBUser* user in joinedUsers)
    {
        user.delegate = self;
        
        GMSMarker* marker = [GMSMarker markerWithPosition:user.coordinate];
        marker.userData = user;
        marker.title = [NSString stringWithFormat:@"%@ %@", [user.lastName length] > 0 ? user.lastName : @"", [user.firstName length] > 0 ? user.firstName : @""];
        marker.icon = [user imageInMarker];
        marker.map = self.googleMapView;
        [markers addObject:marker];
    }
    
	//[self redrawMap];
}

- (void) updateMessages
{
	NSUInteger count = [[[Model sharedInstance].myMessages unreadMessages] count];
	self.labelMessagesCount.text = [NSString stringWithFormat:@"%d", count];
}

- (void) updatePins
{
    for (GMSMarker* marker in markers)
	{
        for (DBUser* user in _users)
        {
            if ([[marker userData] isEqual:user])
            {
                marker.position = user.coordinate;
                break;
            }
        }
	}
        
	if (_selectedUser)
	{
		[self captureUser:_selectedUser];
	}
}

- (void) drawMePolyline
{
    GMSMutablePath* path = [GMSMutablePath path];
    
    for (GMSMarker* marker in route_me)
    {
        [path addCoordinate:marker.position];
    }
    
    pathMeLine = [GMSPolyline polylineWithPath:path];
    pathMeLine.strokeWidth = 3.0;
    pathMeLine.strokeColor = [UIColor blueColor];
    pathMeLine.map = self.googleMapView;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.labelMessagesCount.text = [NSString stringWithFormat:@"%d", [[[Model sharedInstance].myMessages unreadMessages] count]];
    
    UITextField* searchField = (UITextField*)[self.navigationItem.titleView viewWithTag:666];
    UIImageView* searchImage = (UIImageView*)[self.navigationItem.titleView viewWithTag:665];
    
    searchField.hidden = YES;
    searchField.enabled = NO;
    searchImage.hidden = YES;
    
	[_tableVC hideAnimated:NO];
	
	[Model sharedInstance].updateManager.updateBlock = ^(UpdateType type, NSArray* leftUsers, NSArray* joinedUsers)
	{
		switch (type)
		{
			case UpdateTypeMessages:
				[self updateMessages];
				break;
			case UpdateTypeUsers:
				[self updateUsersWithLeftUsers:leftUsers joinedUsers:joinedUsers];
				break;
			case UpdateTypePins:
				[self updatePins];
				break;
			default:
				break;
		}
	};
    
    self.trafficInLabel.text = [[Model sharedInstance].settings friendlyDownloadTraffic];
    self.trafficOutLabel.text = [[Model sharedInstance].settings friendlyUploadTraffic];
    
    if ([self.selectionVC.selectedValues count] > 0)
    {
        // marker has been shared
        sharedUsers = [[NSMutableArray alloc] init];
        
        NSUInteger index = [self.selectionVC.selectedValues firstIndex];
        while (index != NSNotFound)
        {
            DBUser* u = [_filteredUsers objectAtIndex:index];
            [sharedUsers addObject:u];
            
            index = [self.selectionVC.selectedValues indexGreaterThanIndex: index];
        };
        
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
        alert.tag = 200;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* textField = [alert textFieldAtIndex:0];
        textField.placeholder = [DELEGATE localizedStringForKey:@"Enter text"];
        [alert show];
    }
    
    marker_me.icon = [DELEGATE.me imageInMarker];
    [[[GAI sharedInstance] defaultTracker] sendView:@"TrackerVC"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
	[super viewWillDisappear:animated];
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (float) getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng)));
    
    if (degree >= 0)
    {
        return degree;
    }
    else
    {
        return 360 + degree;
    }
}

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

- (void) rotateForDirectionFromCoordinateToCoordinate:(UIView*)view heading:(CLHeading*)heading fromLocation:(CLLocationCoordinate2D)fromLocation toLocation:(CLLocationCoordinate2D)toLocation
{
    float headingDirection = [self getHeadingForDirectionFromCoordinate:fromLocation toCoordinate:toLocation];
    float rotation = headingDirection + 180;
    if (rotation > 360)
    {
        rotation = 360 - rotation;
    }
    
    [UIView animateWithDuration:0.5f animations:^(void)
     {
         [view setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(rotation))];
     }];
    
    /*if (heading.headingAccuracy > 0)
	{
        float fromLatitude = fromLocation.latitude / 180.f * M_PI;
        float fromLongitude = fromLocation.longitude / 180.f * M_PI;
        float toLatitude = toLocation.latitude / 180.f * M_PI;
        float toLongitude = toLocation.longitude / 180.f * M_PI;
        float direction = atan2(sin(toLongitude-fromLongitude)*cos(toLatitude), cos(fromLatitude)*sin(toLatitude)-sin(fromLatitude)*cos(toLatitude)*cos(toLongitude-fromLongitude));
        double directionToSet = (direction * 180.0f / M_PI) - heading.magneticHeading;
        
        [UIView animateWithDuration:0.5f animations:^(void)
		{
            [view setTransform:CGAffineTransformMakeRotation(directionToSet * M_PI/180.f)];
        }];
    }*/
}

- (void) redrawMap
{
    for (GMSMarker* marker in markers)
    {
        marker.map = nil;
    }
    
    [markers removeAllObjects];
    
	for (DBUser* user in _users)
	{
		if (![user.index isEqualToString:DELEGATE.me.index])
		{
            GMSMarker* marker = [GMSMarker markerWithPosition:user.coordinate];
            marker.userData = user;
            marker.title = [NSString stringWithFormat:@"%@ %@", [user.lastName length] > 0 ? user.lastName : @"", [user.firstName length] > 0 ? user.firstName : @""];
            marker.icon = [user imageInMarker];
            marker.map = self.googleMapView;
            [markers addObject:marker];
		}
	}
}

- (void) clearMePolyline
{
    pathMeLine.map = nil;
}

- (void) clearHistoryPolyline
{
    pathHistoryLine.map = nil;
}

- (void) clearRoute
{
    for (GMSMarker* marker in route)
    {
        marker.map = nil;
    }
    
    [route removeAllObjects];
}

- (void) clearHistory
{
    for (GMSMarker* marker in route_me)
    {
        marker.map = nil;
    }
    
    [route_me removeAllObjects];
}

- (IBAction) onUsers
{
    UITextField* searchField = (UITextField*)[self.navigationItem.titleView viewWithTag:666];
    UIImageView* searchImage = (UIImageView*)[self.navigationItem.titleView viewWithTag:665];
    
    if (![_tableVC isTableVisible])
    {
        searchField.hidden = YES;
        searchField.enabled = NO;
        searchImage.hidden = YES;
    }
    else
    {
        searchField.hidden = NO;
        searchField.enabled = YES;
        searchImage.hidden = NO;
    }
    
    [_tableVC setDisplayGroupUser:YES users:_filteredUsers];
	[_tableVC showAnimated:YES];
}

- (void) onLeave:(id)sender
{
    if ([Model sharedInstance].settings.agpsIsOn)
    {
        //NSLog(@"stopMonitoringSignificantLocationChanges");
        [locationManager stopMonitoringSignificantLocationChanges];
    }
    else
    {
        //NSLog(@"stopUpdatingLocation");
        [locationManager stopUpdatingLocation];
    }
    locationManager.delegate = nil;
    
    marker_address.map = nil;
    [addresses removeAllObjects];
    [self clearHistoryPolyline];
    [self clearHistory];
    [self clearRoute];
    
    for (GMSMarker* marker in markers)
    {
        marker.map = nil;
    }
    
    [markers removeAllObjects];
    [self.googleMapView clear];
    self.googleMapView.delegate = nil;
    [self.googleMapView removeFromSuperview];
    self.googleMapView = nil;
    
    [self.group.users removeAllObjects];
	
	[Model sharedInstance].updateManager.updateBlock = nil;
	[_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
	[DELEGATE showActivity];
    
	[self.group leaveWithSuccess:^()
	{
		UIViewController* searchVC = nil;
		for (UIViewController* vc in [self.navigationController viewControllers])
		{
			if ([vc isKindOfClass:NSClassFromString(@"SearchGroupVC")])
			{
				searchVC = vc;
				break;
			}
		}
        
        // clean and save db
        [PPDbManager save];
        
		[DELEGATE hideActivity];
		[self.navigationController popToViewController:searchVC animated:YES];
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TrackerVC" withAction:@"onLeave" withLabel:@"logout" withValue:nil];
	}
	onError:^(NSString* error)
	{
		[DELEGATE hideActivity];
        [DELEGATE showAlertWithMessage:error];
        [self performSelector:@selector(logoutWithDelay) withObject:nil afterDelay:1.0];
	}];
}

- (void) logoutWithDelay
{
    [DELEGATE onLogout:nil];
}

- (void) refreshWithoutClearingHistory
{
    [DELEGATE showActivity];
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TrackerVC" withAction:@"refreshClicked" withLabel:@"click" withValue:nil];
    
    //NSLog(@"updateUsersWithCriteria");
    [self.group updateUsersWithCriteria:@"" withSuccess:^
     {
         //NSLog(@"immediateUpdatePing");
         [[Model sharedInstance].updateManager immediateUpdatePing];
         [DELEGATE hideActivity];
         [self redrawMap];
     } onError:^(NSString *error)
     {
         NSLog(@"failurem, refreshClicked, updateUsersWithCriteria: %@", error);
         [DELEGATE hideActivity];
         [DELEGATE showAlertWithMessage:error];
     }];
}

- (IBAction) refreshClicked:(id)sender
{
    [DELEGATE showActivity];
    
    [self clearRoute];
    [self clearHistory];
    [self clearMePolyline];
    [self clearHistoryPolyline];
    
    [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TrackerVC" withAction:@"refreshClicked" withLabel:@"click" withValue:nil];
    
    //NSLog(@"updateUsersWithCriteria");
    [self.group updateUsersWithCriteria:@"" withSuccess:^
     {
         //NSLog(@"immediateUpdatePing");
         [[Model sharedInstance].updateManager immediateUpdatePing];
         [DELEGATE hideActivity];
         [self redrawMap];
     } onError:^(NSString *error)
     {
         NSLog(@"failurem, refreshClicked, updateUsersWithCriteria: %@", error);
         [DELEGATE hideActivity];
         [DELEGATE showAlertWithMessage:error];
     }];
}

- (IBAction) settingsClicked:(id)sender
{
    NSMutableArray* pollingFrequency = [NSMutableArray array];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Set automatically"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Seldom"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Very seldom"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Average"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Often"]];
	[pollingFrequency addObject:[DELEGATE localizedStringForKey:@"Very often"]];
    
    self.selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	self.selectionVC.title = [DELEGATE localizedStringForKey:@"Polling Server Frequency"];
	self.selectionVC.values = pollingFrequency;
    self.selectionVC.showAGPS = YES;
	
	NSUInteger index = [Model sharedInstance].settings.requestsFrequency;
	self.selectionVC.selectedValues = [NSIndexSet indexSetWithIndex:index];
	[self.navigationController pushViewController:self.selectionVC animated:YES];
}

- (IBAction) towerClicked:(id)sender
{
    //NSLog(@"towerClicked");
    if (!self.towerButton.selected)
    {
        self.towerButton.selected = YES;
        self.satelliteButton.selected = NO;
        
        //NSLog(@"stopUpdatingLocation");
        //NSLog(@"startMonitoringSignificantLocationChanges");
        [locationManager stopUpdatingLocation];
        locationManager = nil;
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startMonitoringSignificantLocationChanges];
        
        if ([locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)])
        {
            locationManager.pausesLocationUpdatesAutomatically = NO;
        }
        
        [Model sharedInstance].settings.agpsIsOn = YES;
        [[Model sharedInstance].settings save];
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TrackerVC" withAction:@"towerClicked" withLabel:@"click" withValue:nil];
    }
}

- (IBAction) satelliteClicked:(id)sender
{
    //NSLog(@"satelliteClicked");
    if (!self.satelliteButton.selected)
    {
        self.towerButton.selected = NO;
        self.satelliteButton.selected = YES;
        
        //NSLog(@"stopMonitoringSignificantLocationChanges");
        //NSLog(@"startUpdatingLocation");
        [locationManager stopMonitoringSignificantLocationChanges];
        locationManager = nil;
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 200;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        if ([locationManager respondsToSelector:@selector(pausesLocationUpdatesAutomatically)])
        {
            locationManager.pausesLocationUpdatesAutomatically = NO;
        }
        
        [Model sharedInstance].settings.agpsIsOn = YES;
        [[Model sharedInstance].settings save];
        
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:@"TrackerVC" withAction:@"satelliteClicked" withLabel:@"click" withValue:nil];
    }
}

- (void) publishStaticMap:(NSString*)message
{
    // make url for image getting
    NSString* baseUrl = @"https://maps.googleapis.com/maps/api/staticmap";
    
    // parameters
    NSString* center = [NSString stringWithFormat:@"%f,%f", self.googleMapView.camera.target.latitude, self.googleMapView.camera.target.longitude];
    NSNumber* zoom = [NSNumber numberWithInteger:self.googleMapView.camera.zoom];
    NSString* size = @"320x480";
    NSString* m = [NSString stringWithFormat:@"color:red|label:I|%f,%f", marker_me.position.latitude, marker_me.position.longitude];
    NSMutableString* path = [NSMutableString stringWithString:@"color:0x0000ff|weight:3"];
    for (int i = 0; (i < [route_me count] && i < 50); i++)
    {
        GMSMarker* marker = [route_me objectAtIndex:i];
        [path appendFormat:@"|%f,%f", marker.position.latitude, marker.position.longitude];
    }
    
    NSString* staticMapUrl = [NSString stringWithFormat:@"%@?center=%@&zoom=%@&size=%@&maptype=roadmap&sensor=true&markers=%@&path=%@&key=AIzaSyBoo19UocgR_Z7uTBSKoRse45BhNvXJm_E", baseUrl, center, zoom, size, m, path];
    
    // encode url
    NSString* encodedUrl = [staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:encodedUrl, @"picture", message, @"message", nil];
    
    [DELEGATE showActivity];
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSString *alertText;
        if (error)
        {
            alertText = [NSString stringWithFormat:@"Error: Domain = %@, Code = %d", error.domain, error.code];
        }
        else
        {
            alertText = [NSString stringWithFormat:@"Posted action, Id: %@", [result objectForKey:@"id"]];
        }
        
        [DELEGATE hideActivity];
        // Show the result in an alert
        [[[UIAlertView alloc] initWithTitle:@"Result" message:alertText delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil] show];
    }];
}

- (void) showPublishAlert
{
    // calculate distance
    CLLocationDistance distance = 0;
    if ([route_me count] > 0)
    {
        GMSMarker* marker = [route_me objectAtIndex:0];
        CLLocation* lastLocation = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
        
        for (int i = 1; (i < [route_me count] && i < 60); i++)
        {
            GMSMarker* m = [route_me objectAtIndex:i];
            CLLocation* nextLocation = [[CLLocation alloc] initWithLatitude:m.position.latitude longitude:m.position.longitude];
            
            distance += [lastLocation distanceFromLocation:nextLocation];
            lastLocation = nextLocation;
        }
    }
    
    NSString* distanceString = nil;
    if(distance < 1000.f)
    {
        distanceString = [NSString stringWithFormat:@"%.1f meters", distance];
    }
    else
    {
        distanceString = [NSString stringWithFormat:@"%.1f kilometers", distance / 1000.f];
    }
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send", nil];
    alert.tag = 100;
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField* textField = [alert textFieldAtIndex:0];
    textField.placeholder =[NSString stringWithFormat:@"Distance: %@", distanceString];
    [alert show];
}

- (IBAction) facebookShareClicked:(id)sender
{
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound)
    {
        [DELEGATE showActivity];
        
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error)
            {
                [DELEGATE hideActivity];
                [self showPublishAlert];
            }
        }];
    }
    else if (!FBSession.activeSession.isOpen)
    {
        [DELEGATE showActivity];
        
        [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error)
            {
                [DELEGATE hideActivity];
                [self showPublishAlert];
            }
        }];
    }
    else
    {
        [self showPublishAlert];
    }
}

- (IBAction) flagButtonClicked:(id)sender
{
    self.flagButton.selected = !self.flagButton.selected;
}

- (IBAction) messagesButtonClicked:(id)sender
{
    ReadMessageListVC* messagesList = (ReadMessageListVC*)[DELEGATE controllerWithName:@"ReadMessageListVC" fromStoryboard:@"TrackerStoryboard"];
    messagesList.delegate = self;
	[self.navigationController pushViewController:messagesList animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass:[AlertMessageVC class]])
	{
		AlertMessageVC* vc = (AlertMessageVC*)segue.destinationViewController;
		vc.group = self.group;
		vc.users = _filteredUsers;
	}
	else if ([segue.identifier isEqualToString:@"TrackerUserVC"])
	{
		UserMapMenuVC* menuVC = (UserMapMenuVC*)_popover.contentViewController;
		TrackerUserVC* vc = (TrackerUserVC*)segue.destinationViewController;
		vc.user = menuVC.user;
		vc.group = self.group;
	}
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    //[self captureUser:nil];
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self.flagButton.selected)
    {
        GMSMarker* marker = [GMSMarker markerWithPosition:coordinate];
        marker.icon = [UIImage imageNamed:@"pin_start.png"];
        marker.map = self.googleMapView;
        [flags addObject:marker];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    DBUser* user = (DBUser*)[marker userData];
    [self displayPopoverForUser:user];
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    id object = (DBUser*)[marker userData];
    
    if ([object isKindOfClass:[DBUser class]])
    {
        DBUser* user = (DBUser*)object;
        if (self.googleMapView.selectedMarker == marker)
        {
            [self displayPopoverForUser:user];
        }
        
        [self captureUser:user];
        
        [self rotateForDirectionFromCoordinateToCoordinate:self.imageArrow heading:nil fromLocation:DELEGATE.me.coordinate toLocation:_selectedUser.coordinate];
    }
    else
    {
        for (GMSMarker* m in flags)
        {
            if (m == marker)
            {
                marker_address = marker;
                _selectedUser = nil;
                self.googleMapView.selectedMarker = marker;
                [self displayPopoverForFlag:marker];
            }
        }
    }
    
    return YES;
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    return nil;
    /*UIView* markerView = nil;
    
    if ([[(DBUser*)[marker userData] index] isEqualToString:DELEGATE.me.index])
    {
        markerView = [TrackerMeAnnotationView view:DELEGATE.me];
        return markerView;
    }
    
    for (GMSMarker* m in markers)
    {
        NSString* id1 = [(DBUser*)[marker userData] index];
        NSString* id2 = [(DBUser*)[m userData] index];
        if ([id1 isEqualToString:id2])
        {
            markerView = [TrackerUserAnnotationView view:(DBUser*)[m userData]];
            return markerView;
        }
    }
    
    markerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"red_pin.png"]];
    
    return markerView;*/
}

- (void)actionPickerCancelled:(id)sender
{
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

#pragma mark - MarkerMenuVCDelegate

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void) doneClicked:(NSNumber*)selectedIndex origin:(id)origin
{
    [self.googleMapView animateToLocation:marker_address.position];
}

- (void) cancelClicked:(id)origin
{
}

- (void) didSelectPickerRow:(NSNumber*)selectedIndex
{
    NSInteger index = [selectedIndex integerValue];
    if (index < [addresses count])
    {
        NSDictionary* place = [addresses objectAtIndex:index];
        
        NSDictionary* geo = [place objectForKey:@"geometry"];
        NSDictionary* loc = [geo objectForKey:@"location"];
        
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude = [[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude = [[loc objectForKey:@"lng"] doubleValue];
        
        marker_address.position = placeCoord;
        [self.googleMapView animateToLocation:placeCoord];
        
        self.googleMapView.selectedMarker = marker_address;
    }
}

- (void) showAddresses
{
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
    NSMutableArray* vicinities = [[NSMutableArray alloc] init];
    
    for (NSDictionary* place in addresses)
    {
        NSString* name = [place objectForKey:@"name"];
        NSString* vicinity = [place objectForKey:@"vicinity"];
        
        [vicinities addObject:[NSString stringWithFormat:@"%@: %@", name, vicinity ? vicinity : @""]];
    }
    
    if ([vicinities count] > 0)
    {
        ActionSheetStringPicker* picker = [ActionSheetStringPicker showPickerWithTitle:@"" rows:vicinities initialSelection:0 target:self successAction:@selector(doneClicked:origin:) cancelAction:@selector(cancelClicked:) origin:self.view];
        picker.didSelectRowAction = @selector(didSelectPickerRow:);
    }
}

- (void) didAddressClick:(GMSMarker*)marker
{
    [DELEGATE showActivity];
    [[Model sharedInstance] searchAddresses:marker.position withSuccess:^(NSArray *results) {
        [addresses removeAllObjects];
        [addresses addObjectsFromArray:results];
        [self showAddresses];
        
        [DELEGATE hideActivity];
    } onError:^(NSString *error) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [DELEGATE hideActivity];
    }];
}

- (void) didShareClick:(GMSMarker*)marker
{
	self.selectionVC = (SelectionVC*)[DELEGATE controllerWithName:@"SelectionVC" fromStoryboard:@"UtilsStoryboard"];
	self.selectionVC.title = [DELEGATE localizedStringForKey:@"Members"];
    self.selectionVC.isMultiSelection = YES;
    
    NSMutableArray* userNames = [NSMutableArray array];
    for (DBUser* u in _filteredUsers)
    {
        NSString* name= [NSString stringWithFormat:@"%@ %@, %@", [u.firstName length] > 0 ? u.firstName : @"", [u.lastName length] > 0 ? u.lastName : @"", u.email];
        [userNames addObject:name];
    }
    self.selectionVC.values = userNames;
    
	[self.navigationController pushViewController:self.selectionVC animated:YES];
}

- (void) didRemoveClick:(GMSMarker*)marker
{
    marker.map = nil;
    [flags removeObject:marker];
    
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
}

#pragma mark UserMapMenuVCDelegate
-(void) userMapMenuVCOnDetailsMessage:(UserMapMenuVC*)object
{
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
    TrackerUserVC* vc = (TrackerUserVC*)[DELEGATE controllerWithName:@"TrackerUserVC" fromStoryboard:@"TrackerStoryboard"];
    vc.user = object.user;
    vc.group = self.group;
    [self.navigationController pushViewController:vc animated:YES];
    
	//[self performSegueWithIdentifier:@"TrackerUserVC" sender:self];
}

- (void) statisticsDidChoose
{
    [_popover dismissPopoverAnimated:YES];
	_popover = nil;
    
    UserStatisticsVC* vc = (UserStatisticsVC*)[DELEGATE controllerWithName:@"UserStatisticsVC" fromStoryboard:@"TrackerStoryboard"];
    vc.statisticsDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"didUpdateLocations new");
    if ([locations count] > 0)
    {
        [self clearMePolyline];
        
        CLLocation* newLocation = [locations lastObject];
        DELEGATE.me.coordinate = newLocation.coordinate;
        marker_me.title = [DELEGATE localizedStringForKey:@"You"];
        marker_me.position = newLocation.coordinate;
        
        GMSMarker* marker = [GMSMarker markerWithPosition:DELEGATE.me.coordinate];
        marker.icon = [UIImage imageNamed:@"direction_you.png"];
        marker.title = [DELEGATE localizedStringForKey:@"You"];
        //!!! marker.map = self.googleMapView;
        [route_me addObject:marker];
        
        [self drawMePolyline];
        
        //NSLog(@"didUpdateToLocation: latitude %f, longitude %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        [DELEGATE.me onUpdatePin:nil];
        if (![Model sharedInstance].backgroundModeActive)
        {
            [self captureUser:_selectedUser];
            
            //NSLog(@"immediateUpdatePing");
            //[[Model sharedInstance].updateManager immediateUpdatePing];
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateLocations old");
    
    [self clearMePolyline];
    
	DELEGATE.me.coordinate = newLocation.coordinate;
    marker_me.title = [DELEGATE localizedStringForKey:@"You"];
    marker_me.position = newLocation.coordinate;
    
    GMSMarker* marker = [GMSMarker markerWithPosition:DELEGATE.me.coordinate];
    marker.icon = [UIImage imageNamed:@"direction_you.png"];
    marker.title = [DELEGATE localizedStringForKey:@"You"];
    //!!! marker.map = self.googleMapView;
    [route_me addObject:marker];
    
    [self drawMePolyline];
    
    //NSLog(@"didUpdateToLocation: latitude %f, longitude %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    [DELEGATE.me onUpdatePin:nil];
    if (![Model sharedInstance].backgroundModeActive)
    {
        [self captureUser:_selectedUser];
        
        //NSLog(@"immediateUpdatePing");
        //[[Model sharedInstance].updateManager immediateUpdatePing];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if(!_selectedUser)
        return;
    
	[self rotateForDirectionFromCoordinateToCoordinate:self.imageArrow heading:newHeading fromLocation:DELEGATE.me.coordinate toLocation:_selectedUser.coordinate];
}

#pragma mark WEPopopoverControllerDelegate
- (void) popoverControllerDidDismissPopover:(WEPopoverController *)popoverController
{
	_tableVC.selectedUser = nil;
	[_popover dismissPopoverAnimated:YES];
	_popover = nil;
}

- (BOOL) popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
{
	return YES;
}

#pragma mark TrackerTableVCDelegate
-(void) needZoomToRegion:(MKCoordinateRegion)region forUser:(DBUser*)user
{
	[self captureUser:user];
    
    UITextField* searchField = (UITextField*)[self.navigationItem.titleView viewWithTag:666];
    UIImageView* searchImage = (UIImageView*)[self.navigationItem.titleView viewWithTag:665];
    
    searchField.hidden = YES;
    searchField.enabled = NO;
    searchImage.hidden = YES;
    
    [self rotateForDirectionFromCoordinateToCoordinate:self.imageArrow heading:nil fromLocation:DELEGATE.me.coordinate toLocation:_selectedUser.coordinate];
}

-(void) needUpdateUsers:(NSArray*)users
{
	_filteredUsers = users;
}

#pragma mark - UITextFieldDelegate
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
		_tableVC.users = [self.group filterUsersWithCriteria:criteria];
	}
	else
	{
		_tableVC.users = self.group.users;
	}
    
	[_tableVC.table reloadData];
    
	return YES;
}

#pragma mark - TrafficProtocol Methods

- (void) trafficChanged:(NSString*)friendlyDownload friendlyUpload:(NSString*)friendlyUpload
{
    self.trafficInLabel.text = friendlyDownload;
    self.trafficOutLabel.text = friendlyUpload;
}

- (void) didDateChoose:(NSDate *)from to:(NSDate *)to
{
    [self.navigationController popViewControllerAnimated:YES];
    [DELEGATE showActivity];
    
    [[Model sharedInstance] trackUser:_selectedUser fromDate:from toDate:to withSuccess:^(NSArray *pins1) {
        [DELEGATE hideActivity];
        
        [self clearHistoryPolyline];
        [self clearRoute];
        
        GMSMutablePath* path = [GMSMutablePath path];
        
        for (Pin* pin in pins1)
        {
            BOOL existes = NO;
            for (GMSMarker* marker in markers)
            {
                if (([marker position].latitude == pin.coordinate.latitude) && ([marker position].longitude == pin.coordinate.longitude))
                {
                    existes = YES;
                    break;
                }
            }
            
            if (!existes)
            {
                for (GMSMarker* marker in route)
                {
                    if (([marker position].latitude == pin.coordinate.latitude) && ([marker position].longitude == pin.coordinate.longitude))
                    {
                        existes = YES;
                        break;
                    }
                }
            }
            
            if (!existes)
            {
                GMSMarker* marker = [GMSMarker markerWithPosition:pin.coordinate];
                marker.userData = pin;
                marker.icon = [UIImage imageNamed:@"direction_friend.png"];
                marker.map = self.googleMapView;
                [route addObject:marker];
                
                [path addCoordinate:pin.coordinate];
            }
        }
        
        pathHistoryLine = [GMSPolyline polylineWithPath:path];
        pathHistoryLine.strokeWidth = 3.0;
        pathHistoryLine.strokeColor = [UIColor redColor];
        pathHistoryLine.map = self.googleMapView;
     
    } onError:^(NSString *error) {
        [DELEGATE hideActivity];
		[DELEGATE showAlertWithMessage:error];
    }];
}

- (void) backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Public Methods

- (void) willBackgroundMode
{
    //self.googleMapView.selectedMarker = nil;
}

- (void) willForegroundMode
{
    if (_selectedUser)
    {
        [self captureUser:_selectedUser];
    }
    
    [self performSelector:@selector(refreshWithoutClearingHistory)];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((alertView.tag == 100) && (buttonIndex == 1))
    {
        UITextField* textField = [alertView textFieldAtIndex:0];
        NSString* message = [NSString stringWithFormat:@"%@\n\n%@", textField.text, textField.placeholder];
        
        [self publishStaticMap:message];
    }
    else if ((alertView.tag == 200) && (buttonIndex == 1))
    {
        UITextField* textField = [alertView textFieldAtIndex:0];
        
        NSString* shareMarkerText = [NSString stringWithFormat:@"gow share marker message:%f,%f,%@", marker_address.position.longitude, marker_address.position.latitude, textField.text];
        DBMessage* message = [DBMessage messageWithText:shareMarkerText image:nil priority:MessagePriorityNormal user:DELEGATE.me];
        
        [DELEGATE showActivity];
        [self.group sendMessage:message toUsers:sharedUsers onSuccess:^{
            [DELEGATE hideActivity];
        } onError:^(NSString *error) {
            [DELEGATE hideActivity];
        }];
    }
    
    sharedUsers = nil;
}

#pragma mark - BackgroundActionsDelegate

- (void) didImageLoad:(id)sender image:(UIImage *)image
{
    DBUser* user = (DBUser*)sender;
    
    for (GMSMarker* marker in markers)
    {
        if (marker.userData == sender)
        {
            marker.icon = [user imageInMarker];
        }
    }
    
    if (DELEGATE.me == user)
    {
        marker_me.icon = [user imageInMarker];
    }
}

#pragma mark - ReadMessageListVCDelegate

- (void) didReadSharedMarkerAfterDelay:(NSDictionary*)parameters
{
    NSNumber* longitude = [parameters objectForKey:@"longitude"];
    NSNumber* latitude = [parameters objectForKey:@"latitude"];
    NSString* text = [parameters objectForKey:@"text"];
    
    CLLocationCoordinate2D position;
    position.longitude = [longitude floatValue];
    position.latitude = [latitude floatValue];
    
    GMSMarker* marker = nil;
    for (GMSMarker* m in flags)
    {
        if ((m.position.longitude == position.longitude) && (m.position.latitude == position.latitude))
        {
            marker = m;
            break;
        }
    }
    
    if (!marker)
    {
        marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"pin_start.png"];
        [flags addObject:marker];
    }
    
    marker.map = self.googleMapView;
    marker.title = text;
    [self.googleMapView animateToLocation:marker.position];
    
    _selectedUser = nil;
    self.googleMapView.selectedMarker = marker;
}

- (void) didReadSharedMarker:(NSDictionary*)parameters
{
    [self performSelector:@selector(didReadSharedMarkerAfterDelay:) withObject:parameters afterDelay:0.7];
}

@end
