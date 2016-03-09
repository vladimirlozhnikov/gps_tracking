//
//  GroupDetailsVC.h
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"
#import "REVClusterMapView.h"
#import <CoreLocation/CoreLocation.h>
#import "UserMapMenuVC.h"
#import "WEPopoverController.h"
#import "TrackerTableVC.h"
#import "Protocol.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@class DBGroup;
@class DBUser;
@class WEPopoverController;
@class TrackerMeAnnotation;

@interface TrackerVC : BaseVC<CLLocationManagerDelegate, UITextFieldDelegate, UserMapMenuVCDelegate, WEPopoverControllerDelegate, TrackerTableVCDelegate, TrafficProtocol, StatisticsProtocol, GMSMapViewDelegate, UIAlertViewDelegate, MarkerMenuVCDelegate, BackgroundActionsDelegate, ReadMessageListVCDelegate>
{
	TrackerTableVC* _tableVC;
	
	NSArray* _filteredUsers;
	NSArray* _users;
    NSMutableArray* route;
    NSMutableArray* route_me;
    NSMutableArray* markers;
    NSMutableArray* flags;
    NSMutableArray* addresses;
	
    NSMutableArray* sharedUsers;
	DBUser* _selectedUser;
	WEPopoverController* _popover;
    GMSMarker* marker_me;
    GMSMarker* marker_address;
		
	BOOL _isTableDisplaysGroupUsers;
	NSArray* _clusterUsers;
    CLLocationManager* locationManager;
    
    GMSPolyline* pathHistoryLine;
    GMSPolyline* pathMeLine;
}

@property (weak, nonatomic) IBOutlet GMSMapView* googleMapView;
@property (weak, nonatomic) IBOutlet UILabel *labelDistanceTo;
@property (weak, nonatomic) IBOutlet UIImageView *imageArrow;
@property (weak, nonatomic) IBOutlet UILabel *labelMessagesCount;
@property (weak, nonatomic) IBOutlet UIButton *buttonUsers;
@property (weak, nonatomic) IBOutlet UIButton* towerButton;
@property (weak, nonatomic) IBOutlet UIButton* satelliteButton;
@property (weak, nonatomic) IBOutlet UIButton* flagButton;

@property (weak, nonatomic) IBOutlet UILabel* trafficInLabel;
@property (weak, nonatomic) IBOutlet UILabel* trafficOutLabel;

@property (nonatomic, weak) DBGroup* group;

- (IBAction) onUsers;
- (IBAction) refreshClicked:(id)sender;
- (IBAction) settingsClicked:(id)sender;
- (IBAction) towerClicked:(id)sender;
- (IBAction) satelliteClicked:(id)sender;
- (IBAction) facebookShareClicked:(id)sender;
- (IBAction) flagButtonClicked:(id)sender;
- (IBAction) messagesButtonClicked:(id)sender;

- (void) willBackgroundMode;
- (void) willForegroundMode;

@end
