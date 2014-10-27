//
//  DistanceTableViewCell.h
//  Yelp
//
//  Created by Rishit Shroff on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DistanceTableViewCell;

@protocol DistanceTableViewCellDelegate <NSObject>

-(void) distanceCell:(DistanceTableViewCell *)cell valueChanged: (BOOL)onOff;
@end

@interface DistanceTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) id<DistanceTableViewCellDelegate> delegate;

@end
