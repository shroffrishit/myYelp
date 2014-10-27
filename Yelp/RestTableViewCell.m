//
//  RestTableViewCell.m
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "RestTableViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface RestTableViewCell()


@end

@implementation RestTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.image.layer.cornerRadius = 3;
    self.image.clipsToBounds = TRUE;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBusiness:(Business *)business {
    _business = business;
    [self.image setImageWithURL:[NSURL URLWithString:self.business.imageURL]];
    [self.ratingImage setImageWithURL:[NSURL URLWithString:self.business.ratingImageURL]];
    self.price.text = @"$$";
    self.name.text = self.business.name;
    self.reviews.text = [NSString stringWithFormat:@"%lu reviews", self.business.numReviews];
    self.addr.text = self.business.address;
    self.type.text = self.business.categories;
    self.dist.text = [NSString stringWithFormat:@"%.2fmi", self.business.distance];
}

@end
