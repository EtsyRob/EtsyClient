//
//  RDEtsyListingTableViewController.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsyClient.h"
#import "RDEtsyClientSearchResult.h"
#import "RDEtsyClientSearchResult+Backfill.h"
#import "RDEtsyListingTableViewCell.h"
#import "RDEtsyListingTableViewController.h"
#import "RDEtsySearchResultItem.h"
#import "RDThumbnailImageCache.h"
#import "UIColor+Hex.h"
#import <SafariServices/SafariServices.h>


static NSString *CellIdentifier = @"basicCellIdentifier";
static NSString *ApiKey = @"liwecjs0c3ssk6let4p1wqt9";
static NSString *DefaultSearchTerm = @"Wooden Chairs";
static NSInteger LoadMoreDataThreshold = 8;



@interface RDEtsyListingTableViewController () <UISearchResultsUpdating>

@property (nonatomic, strong) RDEtsyClientSearchResult *searchResult; // Always modify on main thread
@property (nonatomic, strong) RDEtsyClient *etsyClient;
@property (nonatomic, strong) RDThumbnailImageCache *imageCache;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) BOOL updating;

@end

@implementation RDEtsyListingTableViewController

#pragma mark - Lifecycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    self.etsyClient = [[RDEtsyClient alloc] initWithApiKey:ApiKey];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBarHidden = NO;
    self.imageCache = [[RDThumbnailImageCache alloc] init];
    [self applyTheme];
    [self setupSearchController];
    [self loadDataWithQueryText:DefaultSearchTerm];
}

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)applyTheme {
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"34A8C4"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - Various Methods

- (void)loadDataWithQueryText:(NSString *)queryText {
    //TODO: Should dispatch these onto a queue and only process the current and next search
    [self.etsyClient getListingsWithQueryText:queryText completion:^(RDEtsyClientSearchResult *searchResult) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //Clear the cache whenever we search for new text
            [self.imageCache clearCache];
            self.searchResult = searchResult;
            [self.tableView reloadData];
        });
    }];
}

- (void)loadMoreResults {

    if(!self.updating) {
        self.updating = YES;
        [self.etsyClient getMoreListingsWithSearchResult:self.searchResult completion:^(RDEtsyClientSearchResult *searchResult) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(searchResult) {
                    RDEtsyClientSearchResult *newResults = [RDEtsyClientSearchResult searchResultByPrependingSearchResult:self.searchResult intoSearchResult:searchResult];
                    self.searchResult = newResults;
                } else {
                    self.searchResult = searchResult;
                }
                
                [self.tableView reloadData];
                self.updating = NO;
            });
        }];
    }
}


- (RDEtsySearchResultItem *)searchResultItemAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.searchResult) {
        return nil;
    }
    if(indexPath.row < [self.searchResult.results count]) {
        return self.searchResult.results[indexPath.row];
    }
    return nil;
    
}

- (void)configureCell:(RDEtsyListingTableViewCell *)cell forSearchResultItem:(RDEtsySearchResultItem *)searchResultItem atIndexPath:(NSIndexPath *)indexPath {
    cell.listingTitle.text = searchResultItem.title;
    cell.imageView.image = nil;

    if (searchResultItem.imageURL) {
        [self.imageCache imageForURL:searchResultItem.imageURL completion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Check if the cell is still present in the tableView
                UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
                if([newCell isKindOfClass:[RDEtsyListingTableViewCell class]]) {
                    RDEtsyListingTableViewCell *listingTVC = (RDEtsyListingTableViewCell *)newCell;
                    listingTVC.imageView.image = image;
                    [listingTVC setNeedsLayout];
                }
            });
        }];
    }
}


#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchResult) {
        return [self.searchResult.results count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RDEtsySearchResultItem *searchResultItem = [self searchResultItemAtIndexPath:indexPath];
    if([cell isKindOfClass:[RDEtsyListingTableViewCell class]]) {
        RDEtsyListingTableViewCell *listingTableViewCell = (RDEtsyListingTableViewCell *)cell;
        [self configureCell:listingTableViewCell forSearchResultItem:searchResultItem atIndexPath:indexPath];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if((self.searchResult.results.count - indexPath.row) <= LoadMoreDataThreshold) {
        [self loadMoreResults];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RDEtsySearchResultItem *searchResultItem = [self searchResultItemAtIndexPath:indexPath];
    SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:searchResultItem.listingURL];
    
    [self presentViewController:safariViewController animated:YES completion:nil];
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText;
    if([searchController.searchBar.text isEqualToString:@""]) {
        searchText = DefaultSearchTerm;
    } else {
        searchText = searchController.searchBar.text;
    }
    
    [self loadDataWithQueryText:searchText];
}




@end
