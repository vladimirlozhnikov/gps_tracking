//
//  UserMapMenuVC.h
//  GPSTracker
//
//  Created by YS on 1/19/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"

@class DBUser;

@interface UserMapMenuVC : UIViewController
{
	CGRect _rcButtonPhoneNumber;
	CGRect _rcButtonStats;
	CGRect _rcButtonAbuse;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonStats;
@property (weak, nonatomic) IBOutlet UIButton *buttonPhoneNumber;

@property (weak, nonatomic) id<UserMapMenuVCDelegate> delegate;
@property (nonatomic, weak) DBUser* user;

- (IBAction) onCall;
- (IBAction) onStats;
- (IBAction) onDetailsMessage;

@end
