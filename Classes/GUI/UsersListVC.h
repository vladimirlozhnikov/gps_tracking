//
//  UsersListVC.h
//  GPSTracker
//
//  Created by YS on 1/11/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "BaseVC.h"

@class DBGroup;

@interface UsersListVC : BaseVC<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
	NSArray* _filteredUsers;
}

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSearchCriteria;
@property (weak, nonatomic) IBOutlet UIImageView* tableImage;

@property (weak, nonatomic) DBGroup* group;

- (IBAction) onClose:(id)sender;

@end
