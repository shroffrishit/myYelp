//
//  FilterViewController.h
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol FilterViewControllerDelegate <NSObject>

- (void) filtersViewController:(FilterViewController *)filterViewController
              didChangeFilters:(NSDictionary *)filters;

- (void) filtersViewController:(FilterViewController *)filterViewController
                     cancelled:(BOOL)cancelled;
@end

@interface FilterViewController : UIViewController

@property (nonatomic, weak) id<FilterViewControllerDelegate> delegate;

@end
