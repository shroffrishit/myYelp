//
//  CategoryTableViewCell.h
//  Yelp
//
//  Created by Rishit Shroff on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryTableViewCell;

@protocol CategoryTableViewCellDelegate <NSObject>

-(void) categoryCell:(CategoryTableViewCell *)cell valueChanged:(BOOL)onOff;

@end

@interface CategoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) id<CategoryTableViewCellDelegate> delegate;

@end
