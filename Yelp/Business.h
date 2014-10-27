//
//  Business.h
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Business : NSObject

@property(nonatomic, strong) NSString *imageURL;
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *ratingImageURL;
@property(nonatomic, assign) NSInteger numReviews;
@property(nonatomic, strong) NSString *address;
@property(nonatomic, strong) NSString *categories;
@property(nonatomic, assign) CGFloat distance;

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries;
@end
