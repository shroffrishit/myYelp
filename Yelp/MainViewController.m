//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "RestTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "Business.h"
#import "FilterViewController.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FilterViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSArray *businesses;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *searchString;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self asyncRequest:@"" params:nil];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.table.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
    // Configure the left filter button
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    filterButton.tintColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = filterButton;
    
    self.table.delegate = self;
    self.table.dataSource = self;
    
    // Add the cell nib
    [self.table registerNib:[UINib nibWithNibName:@"RestTableViewCell" bundle:nil] forCellReuseIdentifier:@"RestTableViewCell"];
    self.table.rowHeight = UITableViewAutomaticDimension;
    
    self.searchString = @"";
    self.searchDisplayController.searchBar.text = self.searchString;
    long rgbValue = 0xc41200;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.businesses.count;
}

-(void) onFilterButton {
    FilterViewController *vc = [[FilterViewController alloc] init];
    
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    long rgbValue = 0xc41200;
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
    nvc.navigationBar.translucent = NO;
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void) filtersViewController:(FilterViewController *)filterViewController didChangeFilters:(NSDictionary *)filters {
    [self asyncRequest:self.searchString params:filters];
}

-(void) filtersViewController:(FilterViewController *)filterViewController cancelled:(BOOL)cancelled {
    [self.table reloadData];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RestTableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:@"RestTableViewCell"];
    
    [cell setBusiness:self.businesses[indexPath.row]];
    return cell;
}

-(void)searchBar:(UISearchBar *)searchBar
   textDidChange:(NSString *)searchText {
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self selector:@selector(searchQuery:) userInfo:searchText repeats:NO];
    self.searchString = searchText;
}

- (void)searchQuery:(NSTimer*)timer
{
    self.searchDisplayController.active = FALSE;
    [self asyncRequest:self.searchString params:nil];
    self.searchBar.text = self.searchString;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.hidden = YES;
}

-(void) asyncRequest:(NSString *)term params:(NSDictionary *) params{
    [self.client searchWithTerm:term params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *dictionary = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:dictionary];
        [self.table reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}
@end
