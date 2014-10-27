//
//  SortByTableViewCell.h
//  Yelp
//
//  Created by Rishit Shroff on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SortByTableViewCell;

@protocol SortByTableViewCellDelegate <NSObject>

-(void) sortCell:(SortByTableViewCell *)cell valueChanged: (BOOL)onOff;
@end

@interface SortByTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) id<SortByTableViewCellDelegate> delegate;

@end
