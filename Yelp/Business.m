//
//  Business.m
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *) dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [[NSMutableArray alloc] init];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.name = dictionary[@"name"];
        self.imageURL = dictionary[@"image_url"];
        
        NSString *street = nil;
        
        NSArray *locationArray = dictionary[@"location"][@"address"];
        
        if (locationArray.count > 0) {
            street = dictionary[@"location"][@"address"][0];
        }
        
        NSString *neigbhorhood = dictionary[@"location"][@"neighborhoods"][0];
        
        if (street != nil && neigbhorhood != nil) {
            self.address = [NSString stringWithFormat:@"%@, %@", street, neigbhorhood];
        }
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageURL = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    return self;
}

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    return businesses;
}



@end
