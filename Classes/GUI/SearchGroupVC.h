//
//  SearchGroupVC.h
//  GPSTracker
//
//  Created by YS on 1/10/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "SearchGroupCell.h"
#import "Types.h"
#import "Protocol.h"

@class SelectionVC;
@class DBCountry;
@class DBCity;

@interface SearchGroupVC : BaseVC<UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, SearchGroupCellDelegate, TrafficProtocol>
{
	SelectionVC* _selectionVC;
	
	enum
	{
		SearchSelectionModeCountry = 0,
		SearchSelectionModeCity,
		SearchSelectionModeRadius,
		SearchSelectionModeCount
	}_selectionMode;

	NSMutableArray* _cities;
	NSMutableArray* _radiusValues;
	
	DBCountry* _country;
	DBCity* _city;
	Radius _radius;
	
	NSMutableArray* _searchResults;
    NSMutableArray* expandedSections;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *buttonCountry;
@property (weak, nonatomic) IBOutlet UIButton *buttonCity;
@property (weak, nonatomic) IBOutlet UIButton *buttonRadius;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;

@property (weak, nonatomic) IBOutlet UILabel* trafficInLabel;
@property (weak, nonatomic) IBOutlet UILabel* trafficOutLabel;

- (IBAction) onCountry;
- (IBAction) onCity;
- (IBAction) onRadius;
- (IBAction) onClose:(id)sender;

@end
