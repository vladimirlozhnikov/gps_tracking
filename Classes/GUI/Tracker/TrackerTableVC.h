//
//  TrackerTableVC.h
//  GPSTracker
//
//  Created by YS on 2/5/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DBUser;
@class DBGroup;

@protocol TrackerTableVCDelegate <NSObject>

- (NSString*) distanceToUser:(DBUser*)user kmHOnly:(BOOL)kmHOnly;
- (void) needZoomToRegion:(MKCoordinateRegion)region forUser:(DBUser*)user;
- (void) needUpdateUsers:(NSArray*)users;

@end

@interface TrackerTableVC : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
	DBUser* _selectedUser;
	BOOL _isDisplayGroupUsers;
}

@property (nonatomic, readonly) BOOL isDisplayGroupUsers;
@property (nonatomic, weak) id<TrackerTableVCDelegate> delegate;
@property (nonatomic, weak) DBUser* selectedUser;
@property (nonatomic, weak) DBGroup* group;
@property (nonatomic, strong) NSArray* users;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;

- (void) showAnimated:(BOOL)animated;
- (void) hideAnimated:(BOOL)animated;
- (BOOL) isTableVisible;

- (void) setDisplayGroupUser:(BOOL)display users:(NSArray*)users;
- (IBAction) onHide;

@end
