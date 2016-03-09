//
//  UserStatisticsVC.m
//  GPSTracker
//
//  Created by vladimir.lozhnikov on 09.04.13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import "UserStatisticsVC.h"
#import "DateUtils.h"

@interface UserStatisticsVC ()

@end

@implementation UserStatisticsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    self.datePicker.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.datePicker setMaximumDate:[NSDate date]];
    self.to = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    self.from = [[NSDate alloc] initWithTimeIntervalSinceNow:-(60 * 60 * 5)];
    
    self.fromLabel.text = [DateUtils stringFromDate:self.from];
    self.toLabel.text = [DateUtils stringFromDate:self.to];
    
    // resize make photo image
    UIImage* normalOkImage = [UIImage imageNamed:@"done_button.png"];
    UIImage* highlightedOkImage = [UIImage imageNamed:@"done_button_press.png"];
    UIImage* resizeNormalOkImage = [normalOkImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    UIImage* resizeHighlightedOkImage = [highlightedOkImage stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
    
    [self.okButton setBackgroundImage:resizeNormalOkImage forState:UIControlStateNormal];
    [self.okButton setBackgroundImage:resizeHighlightedOkImage forState:UIControlStateHighlighted];
    
    // back button
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 59.0, 35.0)];
    [backButton setImage:[UIImage imageNamed:@"back_button.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back_button_press.png"] forState:UIControlStateHighlighted];
    
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers

- (IBAction) fromClicked:(id)sender
{
    self.datePicker.date = self.from;
    
    self.datePicker.hidden = NO;
    self.okButton.selected = YES;
    
    dateType = fromType;
}

- (IBAction) toClicked:(id)sender
{
    self.datePicker.date = self.to;
    
    self.datePicker.hidden = NO;
    self.okButton.selected = YES;
    
    dateType = toType;
}

- (IBAction) okClicked:(id)sender
{
    if (self.okButton.selected == NO)
    {
        [self.statisticsDelegate performSelector:@selector(didDateChoose:to:) withObject:self.from withObject:self.to];
    }
    else
    {
        if (dateType == fromType)
        {
            self.from = [[NSDate alloc] initWithTimeIntervalSince1970:[self.datePicker.date timeIntervalSince1970]];
            
            self.fromLabel.text = [DateUtils stringFromDate:self.from];
        }
        else if (dateType == toType)
        {
            self.to = [[NSDate alloc] initWithTimeIntervalSince1970:[self.datePicker.date timeIntervalSince1970]];
            
            self.toLabel.text = [DateUtils stringFromDate:self.to];
        }
        
        self.datePicker.hidden = YES;
    }
    
    self.okButton.selected = NO;
}

- (void) onBack:(id) sender
{
    [self.statisticsDelegate performSelector:@selector(backClicked)];
}

@end
