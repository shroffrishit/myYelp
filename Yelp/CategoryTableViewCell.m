//
//  CategoryTableViewCell.m
//  Yelp
//
//  Created by Rishit Shroff on 10/26/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "CategoryTableViewCell.h"

@implementation CategoryTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.onOffSwitch addTarget:self action:@selector(toggleValueChanged) forControlEvents:UIControlEventValueChanged];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void) toggleValueChanged {
    [self.delegate categoryCell:self valueChanged:self.onOffSwitch.isOn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
