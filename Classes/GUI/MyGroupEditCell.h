//
//  MyGroupEditCell.h
//  GPSTracker
//
//  Created by YS on 2/20/13.
//  Copyright (c) 2013 Yury Shubin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyGroupEditCell;

@protocol MyGroupEditCellDelegate <NSObject>

-(void) cell:(MyGroupEditCell*)cell isLeft:(BOOL)isLeft;

@end

@interface MyGroupEditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *buttonLeft;
@property (weak, nonatomic) IBOutlet UIButton *buttonRight;
@property (nonatomic, weak) id<MyGroupEditCellDelegate> delegate;

- (IBAction) onRight;
- (IBAction) onLeft;

@end
