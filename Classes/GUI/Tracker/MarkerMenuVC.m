//
//  MarkerMenuVC.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 14.06.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "MarkerMenuVC.h"

@interface MarkerMenuVC ()

@end

@implementation MarkerMenuVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) addressButtonClicked:(id)sender
{
    [self.delegate didAddressClick:self.marker];
}

- (IBAction) shareButtonClicked:(id)sender
{
    [self.delegate didShareClick:self.marker];
}

- (IBAction) removeButtonClicked:(id)sender
{
    [self.delegate didRemoveClick:self.marker];
}

@end
