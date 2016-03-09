//
//  MarkerMenuVC.h
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 14.06.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Protocol.h"

@interface MarkerMenuVC : UIViewController
{
    CGRect rectAddress;
	CGRect rectRemove;
}

@property (weak, nonatomic) IBOutlet UIButton* addressButton;
@property (weak, nonatomic) IBOutlet UIButton* shareButton;
@property (weak, nonatomic) IBOutlet UIButton* removeButton;

@property (weak, nonatomic) GMSMarker* marker;
@property (weak, nonatomic) id<MarkerMenuVCDelegate> delegate;

- (IBAction) addressButtonClicked:(id)sender;
- (IBAction) shareButtonClicked:(id)sender;
- (IBAction) removeButtonClicked:(id)sender;

@end
