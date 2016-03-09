//
//  BaseTableCell.h
//  PatientProgress
//
//  Created by vladimir.lozhnikov on 14.02.13.
//  Copyright (c) 2013 intellectsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableCell : UITableViewCell
{
}

+ (id)cellFromNibNamed:(NSString *)nibName owner:(id)owner;

@end
