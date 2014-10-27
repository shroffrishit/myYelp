//
//  FilterViewController.m
//  Yelp
//
//  Created by Rishit Shroff on 10/25/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "FilterViewController.h"
#import "DealViewCell.h"
#import "CategoryTableViewCell.h"
#import "DistanceTableViewCell.h"
#import "SortByTableViewCell.h"

@interface FilterViewController () <UITableViewDelegate, UITableViewDataSource, CategoryTableViewCellDelegate, DealViewCellDelegate, DistanceTableViewCellDelegate, SortByTableViewCellDelegate>

@property (nonatomic, strong) NSArray *sectionTitles;
@property (weak, nonatomic) IBOutlet UITableView *filterTable;

@property (strong, nonatomic) NSArray* categoryOptions;
@property (strong, nonatomic) NSMutableSet* selectedCategories;

@property (strong, nonatomic) NSArray* sortOptions;
@property (strong, nonatomic) NSMutableSet* sortByCells;
@property (strong, nonatomic) NSIndexPath* selectedSortOption;
@property (strong, nonatomic) SortByTableViewCell *selectedSortCell;

@property (strong, nonatomic) NSArray* distanceOptions;
@property (strong, nonatomic) NSMutableSet* distanceCells;
@property (strong, nonatomic) NSIndexPath* selectedDistanceOption;
@property (strong, nonatomic) DistanceTableViewCell *selectedDistCell;

@property (assign, nonatomic) BOOL dealOptionSelected;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Configure the left filter button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    cancelButton.tintColor = [UIColor blackColor];

    
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    self.navigationItem.rightBarButtonItem = applyButton;
    applyButton.tintColor = [UIColor blackColor];

    
    if (self) {
        [self initializeCategories];
        [self initializeSortOptions];
        [self initializeDistanceOptions];
        
        self.selectedCategories = [NSMutableSet set];
        
        self.sectionTitles = @[
                               [@{
                                   @"name" : @"Sort by",
                                   @"rowcount" : @3,
                                   @"expanded" : @FALSE,
                                   @"default_rows" : @1
                                   } mutableCopy],
                               [@{
                                   @"name" : @"Distance",
                                   @"rowcount" : @5,
                                   @"expanded" : @FALSE,
                                   @"default_rows" : @1
                                   } mutableCopy],
                               [@{
                                   @"name" : @"Deals",
                                   @"rowcount" : @1,
                                   @"expanded" : @TRUE,
                                   @"default_rows" : @1
                                   } mutableCopy],
                               [@{
                                   @"name" : @"Category",
                                   @"rowcount": @169,
                                   @"expanded" : @FALSE,
                                   @"default_rows" : @5
                                } mutableCopy]
                               ];
    }
    self.filterTable.delegate = self;
    self.filterTable.dataSource = self;
    
    [self.filterTable registerNib:[UINib nibWithNibName:@"DealViewCell" bundle:nil]
           forCellReuseIdentifier:@"DealViewCell"];
    [self.filterTable registerNib:[UINib nibWithNibName:@"CategoryTableViewCell" bundle:nil] forCellReuseIdentifier:@"CategoryTableViewCell"];
    [self.filterTable registerNib:[UINib nibWithNibName:@"DistanceTableViewCell" bundle:nil] forCellReuseIdentifier:@"DistanceTableViewCell"];
    [self.filterTable registerNib:[UINib nibWithNibName:@"SortByTableViewCell" bundle:nil] forCellReuseIdentifier:@"SortByTableViewCell"];
    
    self.sortByCells = [NSMutableSet set];
    self.distanceCells = [NSMutableSet set];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onCancelButton {
    [self.delegate filtersViewController:self cancelled:true];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *cats = [NSMutableArray array];
        for (NSString *cat in self.selectedCategories) {
            [cats addObject:cat];
        }
        NSString *value = [cats componentsJoinedByString:@","];
        [filters setObject:value forKey:@"category_filter"];
    }
    
    if (self.selectedSortOption != nil && self.selectedSortCell.onOffSwitch.isOn) {
        NSString *code = self.sortOptions[self.selectedSortOption.row][@"code"];
        [filters setObject:code forKey:@"sort"];
    }
    
    if (self.selectedDistCell != nil && self.selectedDistCell.onOffSwitch.isOn) {
        float milesPerMeter = 0.000621371;
        float selectedDistance = [self.distanceOptions[self.selectedDistanceOption.row][@"code"] floatValue];

        float distance = selectedDistance / milesPerMeter;
        [filters setObject:[NSNumber numberWithInt:distance] forKey:@"radius_filter"];
    }
    
    if (self.dealOptionSelected) {
        [filters setObject:@YES forKey:@"deals_filter"];
    }
    
    NSLog(@"Query params %@", filters);
    return filters;
}

- (void) onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSDictionary *sectionInfo = self.sectionTitles[section];
    
    BOOL expanded = [sectionInfo[@"expanded"] boolValue];
    
    if (expanded) {
        return [self.sectionTitles[section][@"rowcount"] integerValue];
    } else {
        return [self.sectionTitles[section][@"default_rows"] integerValue];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([@"Category" isEqualToString:self.sectionTitles[indexPath.section][@"name"]]) {
        return [self categoryCell:indexPath];
    } else if ([@"Sort by" isEqualToString:self.sectionTitles[indexPath.section][@"name"]]) {
        return [self sortCell:indexPath];
    } else if ([@"Distance" isEqualToString:self.sectionTitles[indexPath.section][@"name"]]) {
        return [self distanceCell:indexPath];
    } else if ([@"Deals" isEqualToString:self.sectionTitles[indexPath.section][@"name"]]) {
        return [self dealCell:indexPath];
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section][@"name"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL expanded = [self isExpanded:indexPath];
    
    if (!expanded) {
        [self setExpanded:indexPath.section expanded:true];
    } else {
        [self setExpanded:indexPath.section expanded:false];
    }
    [self.filterTable reloadData];
}


-(BOOL) isExpanded:(NSIndexPath *)indexPath {
    NSDictionary *sectionInfo = self.sectionTitles[indexPath.section];
    return [sectionInfo[@"expanded"] boolValue];
}

-(BOOL) setExpanded:(NSInteger)section expanded:(BOOL) expand {
    
    NSMutableDictionary *sectionInfo = self.sectionTitles[section];
    
    BOOL prevValue = [sectionInfo[@"expanded"] boolValue];
    [sectionInfo setValue:[NSNumber numberWithBool:expand] forKey:@"expanded"];
    
    return prevValue;
}

#pragma - SortBy Private Methods

- (UITableViewCell *) sortCell:(NSIndexPath *)indexPath {
    
    SortByTableViewCell *cell = nil;
    BOOL expanded = [self isExpanded:indexPath];
    if (expanded || self.selectedSortOption == nil) {
        cell = [self.filterTable dequeueReusableCellWithIdentifier:
                              @"SortByTableViewCell" forIndexPath:indexPath];
    } else {
        cell = self.selectedSortCell;
        return cell;
    }
    
    cell.title.text = self.sortOptions[indexPath.row][@"name"];

    if (indexPath.row == self.selectedSortOption.row) {
        cell.onOffSwitch.on = TRUE;
    } else {
        cell.onOffSwitch.on = FALSE;
    }
    
    cell.delegate = self;
    [self.sortByCells addObject:cell];
    return cell;
}

- (void) sortCell:(SortByTableViewCell *)cell valueChanged:(BOOL)onOff {
    
    self.selectedSortOption = [self.filterTable indexPathForCell:cell];
    self.selectedSortCell = cell;

    if (!onOff) {
        self.selectedSortOption = nil;
        return;
    }
    
    for (SortByTableViewCell *sortCell in self.sortByCells) {
        if (cell != sortCell) {
            sortCell.onOffSwitch.on = false;
        }
    }
    
    bool wasExpanded = [self setExpanded:self.selectedSortOption.section expanded:false];
    
    if (wasExpanded) {
        [self.filterTable reloadData];
    }
}

#pragma - Distance Private Methods

- (UITableViewCell *) distanceCell:(NSIndexPath *)indexPath {
    
    DistanceTableViewCell *cell = nil;
    BOOL expanded = [self isExpanded:indexPath];
    
    if (expanded || self.selectedDistanceOption == nil) {
        cell = [self.filterTable dequeueReusableCellWithIdentifier:
                          @"DistanceTableViewCell" forIndexPath:indexPath];
    } else {
        cell = self.selectedDistCell;
        return cell;
    }
    
    cell.title.text = self.distanceOptions[indexPath.row][@"name"];
    
    if (indexPath.row == self.selectedDistanceOption.row) {
        cell.onOffSwitch.on = true;
    } else {
        cell.onOffSwitch.on = false;
    }
    
    [self.distanceCells addObject:cell];
    cell.delegate = self;

    return cell;
}

-(void) distanceCell:(DistanceTableViewCell *)cell valueChanged:(BOOL)onOff {
    
    self.selectedDistanceOption = [self.filterTable indexPathForCell:cell];
    self.selectedDistCell = cell;
    
    if (!onOff) {
        return;
    }
    
    for (DistanceTableViewCell *distanceCell in self.distanceCells) {
        if (cell != distanceCell) {
            distanceCell.onOffSwitch.on = false;
        }
    }
    
    bool wasExpanded = [self setExpanded:self.selectedDistanceOption.section expanded:false];
    
    if (wasExpanded) {
        [self.filterTable reloadData];
    }
}

#pragma - Deal Private Methods

- (UITableViewCell *) dealCell:(NSIndexPath *)indexPath {
    DealViewCell *cell = [self.filterTable dequeueReusableCellWithIdentifier:@"DealViewCell" forIndexPath:indexPath];
    cell.title.text = @"Deals";
    cell.delegate = self;
    cell.onOffSwitch.on = self.dealOptionSelected;
    return cell;
}

- (void) dealCell:(DealViewCell *)cell valueChanged:(BOOL)onOff {
    if (onOff) {
        self.dealOptionSelected = true;
    } else {
        self.dealOptionSelected = false;
    }
}

#pragma - Category Private Methods

- (UITableViewCell *) categoryCell:(NSIndexPath *)indexPath {
    CategoryTableViewCell *cell = [self.filterTable dequeueReusableCellWithIdentifier:@"CategoryTableViewCell" forIndexPath:indexPath];

    cell.title.text = self.categoryOptions[indexPath.row][@"name"];
    cell.delegate = self;
    NSString *code = self.categoryOptions[indexPath.row][@"code"];
                                                         
    cell.onOffSwitch.on = [self.selectedCategories containsObject:code];
    
    long limit = [self.sectionTitles[indexPath.section][@"default_rows"] integerValue];
    
    // show the option of see more
    if (limit == indexPath.row + 1) {
        if (![self isExpanded:indexPath]) {
            cell.title.text = @"See More";
            cell.onOffSwitch.hidden = true;
        } else {
            cell.onOffSwitch.hidden = false;
        }
    }
    
    return cell;
}

- (void) categoryCell:(CategoryTableViewCell *)cell valueChanged:(BOOL)onOff {
    NSIndexPath *indexPath = [self.filterTable indexPathForCell:cell];
    
    long limit = [self.sectionTitles[indexPath.section][@"default_rows"] integerValue];

    if (indexPath.row + 1 == limit && ![self isExpanded:indexPath]) {
        [self setExpanded:indexPath.section expanded:true];
        [self.filterTable reloadData];
    }
    
    if (!onOff) {
        [self.selectedCategories removeObject:self.categoryOptions[indexPath.row][@"code"]];
    } else {
        [self.selectedCategories addObject:self.categoryOptions[indexPath.row][@"code"]];
    }
    
}

#pragma - Init Methods

-(void) initializeSortOptions {
    self.sortOptions = @[@{@"name" : @"Best Match", @"code" : @"0"},
                         @{@"name" : @"Distance", @"code" : @"1"},
                         @{@"name" : @"Highest Rated", @"code" : @"2"},
                         ];
}

-(void) initializeDistanceOptions {
    self.distanceOptions = @[@{@"name" : @"Auto", @"code" : @"1"},
                             @{@"name" : @"0.3 miles", @"code" : @"0.3"},
                             @{@"name" : @"1 miles", @"code" : @"1"},
                             @{@"name" : @"5 miles", @"code" : @"5"},
                             @{@"name" : @"20 miles", @"code" : @"20"},
                             ];
}

-(void) initializeCategories {
    
    self.categoryOptions = @[@{@"name" : @"Afghan", @"code": @"afghani" },
                             @{@"name" : @"African", @"code": @"african" },
                             @{@"name" : @"American, New", @"code": @"newamerican" },
                             @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
                             @{@"name" : @"Arabian", @"code": @"arabian" },
                             @{@"name" : @"Argentine", @"code": @"argentine" },
                             @{@"name" : @"Armenian", @"code": @"armenian" },
                             @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
                             @{@"name" : @"Asturian", @"code": @"asturian" },
                             @{@"name" : @"Australian", @"code": @"australian" },
                             @{@"name" : @"Austrian", @"code": @"austrian" },
                             @{@"name" : @"Baguettes", @"code": @"baguettes" },
                             @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
                             @{@"name" : @"Barbeque", @"code": @"bbq" },
                             @{@"name" : @"Basque", @"code": @"basque" },
                             @{@"name" : @"Bavarian", @"code": @"bavarian" },
                             @{@"name" : @"Beer Garden", @"code": @"beergarden" },
                             @{@"name" : @"Beer Hall", @"code": @"beerhall" },
                             @{@"name" : @"Beisl", @"code": @"beisl" },
                             @{@"name" : @"Belgian", @"code": @"belgian" },
                             @{@"name" : @"Bistros", @"code": @"bistros" },
                             @{@"name" : @"Black Sea", @"code": @"blacksea" },
                             @{@"name" : @"Brasseries", @"code": @"brasseries" },
                             @{@"name" : @"Brazilian", @"code": @"brazilian" },
                             @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
                             @{@"name" : @"British", @"code": @"british" },
                             @{@"name" : @"Buffets", @"code": @"buffets" },
                             @{@"name" : @"Bulgarian", @"code": @"bulgarian" },
                             @{@"name" : @"Burgers", @"code": @"burgers" },
                             @{@"name" : @"Burmese", @"code": @"burmese" },
                             @{@"name" : @"Cafes", @"code": @"cafes" },
                             @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
                             @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
                             @{@"name" : @"Cambodian", @"code": @"cambodian" },
                             @{@"name" : @"Canadian", @"code": @"New)" },
                             @{@"name" : @"Canteen", @"code": @"canteen" },
                             @{@"name" : @"Caribbean", @"code": @"caribbean" },
                             @{@"name" : @"Catalan", @"code": @"catalan" },
                             @{@"name" : @"Chech", @"code": @"chech" },
                             @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
                             @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
                             @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
                             @{@"name" : @"Chilean", @"code": @"chilean" },
                             @{@"name" : @"Chinese", @"code": @"chinese" },
                             @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
                             @{@"name" : @"Corsican", @"code": @"corsican" },
                             @{@"name" : @"Creperies", @"code": @"creperies" },
                             @{@"name" : @"Cuban", @"code": @"cuban" },
                             @{@"name" : @"Curry Sausage", @"code": @"currysausage" },
                             @{@"name" : @"Cypriot", @"code": @"cypriot" },
                             @{@"name" : @"Czech", @"code": @"czech" },
                             @{@"name" : @"Czech/Slovakian", @"code": @"czechslovakian" },
                             @{@"name" : @"Danish", @"code": @"danish" },
                             @{@"name" : @"Delis", @"code": @"delis" },
                             @{@"name" : @"Diners", @"code": @"diners" },
                             @{@"name" : @"Dumplings", @"code": @"dumplings" },
                             @{@"name" : @"Eastern European", @"code": @"eastern_european" },
                             @{@"name" : @"Ethiopian", @"code": @"ethiopian" },
                             @{@"name" : @"Fast Food", @"code": @"hotdogs" },
                             @{@"name" : @"Filipino", @"code": @"filipino" },
                             @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
                             @{@"name" : @"Fondue", @"code": @"fondue" },
                             @{@"name" : @"Food Court", @"code": @"food_court" },
                             @{@"name" : @"Food Stands", @"code": @"foodstands" },
                             @{@"name" : @"French", @"code": @"french" },
                             @{@"name" : @"French Southwest", @"code": @"sud_ouest" },
                             @{@"name" : @"Galician", @"code": @"galician" },
                             @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
                             @{@"name" : @"Georgian", @"code": @"georgian" },
                             @{@"name" : @"German", @"code": @"german" },
                             @{@"name" : @"Giblets", @"code": @"giblets" },
                             @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
                             @{@"name" : @"Greek", @"code": @"greek" },
                             @{@"name" : @"Halal", @"code": @"halal" },
                             @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
                             @{@"name" : @"Heuriger", @"code": @"heuriger" },
                             @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
                             @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
                             @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
                             @{@"name" : @"Hot Pot", @"code": @"hotpot" },
                             @{@"name" : @"Hungarian", @"code": @"hungarian" },
                             @{@"name" : @"Iberian", @"code": @"iberian" },
                             @{@"name" : @"Indian", @"code": @"indpak" },
                             @{@"name" : @"Indonesian", @"code": @"indonesian" },
                             @{@"name" : @"International", @"code": @"international" },
                             @{@"name" : @"Irish", @"code": @"irish" },
                             @{@"name" : @"Island Pub", @"code": @"island_pub" },
                             @{@"name" : @"Israeli", @"code": @"israeli" },
                             @{@"name" : @"Italian", @"code": @"italian" },
                             @{@"name" : @"Japanese", @"code": @"japanese" },
                             @{@"name" : @"Jewish", @"code": @"jewish" },
                             @{@"name" : @"Kebab", @"code": @"kebab" },
                             @{@"name" : @"Korean", @"code": @"korean" },
                             @{@"name" : @"Kosher", @"code": @"kosher" },
                             @{@"name" : @"Kurdish", @"code": @"kurdish" },
                             @{@"name" : @"Laos", @"code": @"laos" },
                             @{@"name" : @"Laotian", @"code": @"laotian" },
                             @{@"name" : @"Latin American", @"code": @"latin" },
                             @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
                             @{@"name" : @"Lyonnais", @"code": @"lyonnais" },
                             @{@"name" : @"Malaysian", @"code": @"malaysian" },
                             @{@"name" : @"Meatballs", @"code": @"meatballs" },
                             @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
                             @{@"name" : @"Mexican", @"code": @"mexican" },
                             @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
                             @{@"name" : @"Milk Bars", @"code": @"milkbars" },
                             @{@"name" : @"Modern Australian", @"code": @"modern_australian" },
                             @{@"name" : @"Modern European", @"code": @"modern_european" },
                             @{@"name" : @"Mongolian", @"code": @"mongolian" },
                             @{@"name" : @"Moroccan", @"code": @"moroccan" },
                             @{@"name" : @"New Zealand", @"code": @"newzealand" },
                             @{@"name" : @"Night Food", @"code": @"nightfood" },
                             @{@"name" : @"Norcinerie", @"code": @"norcinerie" },
                             @{@"name" : @"Open Sandwiches", @"code": @"opensandwiches" },
                             @{@"name" : @"Oriental", @"code": @"oriental" },
                             @{@"name" : @"Pakistani", @"code": @"pakistani" },
                             @{@"name" : @"Parent Cafes", @"code": @"eltern_cafes" },
                             @{@"name" : @"Parma", @"code": @"parma" },
                             @{@"name" : @"Persian/Iranian", @"code": @"persian" },
                             @{@"name" : @"Peruvian", @"code": @"peruvian" },
                             @{@"name" : @"Pita", @"code": @"pita" },
                             @{@"name" : @"Pizza", @"code": @"pizza" },
                             @{@"name" : @"Polish", @"code": @"polish" },
                             @{@"name" : @"Portuguese", @"code": @"portuguese" },
                             @{@"name" : @"Potatoes", @"code": @"potatoes" },
                             @{@"name" : @"Poutineries", @"code": @"poutineries" },
                             @{@"name" : @"Pub Food", @"code": @"pubfood" },
                             @{@"name" : @"Rice", @"code": @"riceshop" },
                             @{@"name" : @"Romanian", @"code": @"romanian" },
                             @{@"name" : @"Rotisserie Chicken", @"code": @"rotisserie_chicken" },
                             @{@"name" : @"Rumanian", @"code": @"rumanian" },
                             @{@"name" : @"Russian", @"code": @"russian" },
                             @{@"name" : @"Salad", @"code": @"salad" },
                             @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
                             @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
                             @{@"name" : @"Scottish", @"code": @"scottish" },
                             @{@"name" : @"Seafood", @"code": @"seafood" },
                             @{@"name" : @"Serbo Croatian", @"code": @"serbocroatian" },
                             @{@"name" : @"Signature Cuisine", @"code": @"signature_cuisine" },
                             @{@"name" : @"Singaporean", @"code": @"singaporean" },
                             @{@"name" : @"Slovakian", @"code": @"slovakian" },
                             @{@"name" : @"Soul Food", @"code": @"soulfood" },
                             @{@"name" : @"Soup", @"code": @"soup" },
                             @{@"name" : @"Southern", @"code": @"southern" },
                             @{@"name" : @"Spanish", @"code": @"spanish" },
                             @{@"name" : @"Steakhouses", @"code": @"steak" },
                             @{@"name" : @"Sushi Bars", @"code": @"sushi" },
                             @{@"name" : @"Swabian", @"code": @"swabian" },
                             @{@"name" : @"Swedish", @"code": @"swedish" },
                             @{@"name" : @"Swiss Food", @"code": @"swissfood" },
                             @{@"name" : @"Tabernas", @"code": @"tabernas" },
                             @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
                             @{@"name" : @"Tapas Bars", @"code": @"tapas" },
                             @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
                             @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
                             @{@"name" : @"Thai", @"code": @"thai" },
                             @{@"name" : @"Traditional Norwegian", @"code": @"norwegian" },
                             @{@"name" : @"Traditional Swedish", @"code": @"traditional_swedish" },
                             @{@"name" : @"Trattorie", @"code": @"trattorie" },
                             @{@"name" : @"Turkish", @"code": @"turkish" },
                             @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
                             @{@"name" : @"Uzbek", @"code": @"uzbek" },
                             @{@"name" : @"Vegan", @"code": @"vegan" },
                             @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
                             @{@"name" : @"Venison", @"code": @"venison" },
                             @{@"name" : @"Vietnamese", @"code": @"vietnamese" },
                             @{@"name" : @"Wok", @"code": @"wok" },
                             @{@"name" : @"Wraps", @"code": @"wraps" },
                             @{@"name" : @"Yugoslav", @"code": @"yugoslav" }];
}
@end
