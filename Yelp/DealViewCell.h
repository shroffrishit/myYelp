//
//  DealViewCell.h
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DealViewCell;

@protocol DealViewCellDelegate <NSObject>

-(void) dealCell:(DealViewCell *)cell valueChanged:(BOOL)onOff;
@end

@interface DealViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (weak, nonatomic) id<DealViewCellDelegate> delegate;

@end
