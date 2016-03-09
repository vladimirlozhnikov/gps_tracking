//
//  BaseTableCell.m
//  PatientProgress
//
//  Created by vladimir.lozhnikov on 14.02.13.
//  Copyright (c) 2013 intellectsoft. All rights reserved.
//

#import "BaseTableCell.h"
#import "AppDelegate.h"

@implementation BaseTableCell

+ (id)cellFromNibNamed:(NSString *)nibName owner:(id)owner
{
    NSArray* xib = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:nil];
    id cell = [xib objectAtIndex:0];
    
    return cell;
}

@end
