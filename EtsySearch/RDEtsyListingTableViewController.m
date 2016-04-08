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

@interface RDEtsyListingTableViewController () <UISearchResultsUpdating, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) RDEtsyClientSearchResult *searchResult; // Always modify on main thread
@property (nonatomic, strong) RDEtsyClient *etsyClient;
@property (nonatomic, strong) RDThumbnailImageCache *imageCache;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic) BOOL updating;
@property (nonatomic, strong) NSOperationQueue *searchOperationQueue;
@property (nonatomic, strong) NSString *currentSearchText;

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
    
    
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
}

- (void)setupSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)applyTheme {
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"34A8C4"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - Getters & Setters

- (NSOperationQueue *)searchOperationQueue {
    if(!_searchOperationQueue) {
        _searchOperationQueue = [[NSOperationQueue alloc] init];
        _searchOperationQueue.maxConcurrentOperationCount = 1;
        _searchOperationQueue.name = @"com.rob.etsySample";
    }
    
    return _searchOperationQueue;
}

#pragma mark - Various Methods


- (void)loadDataWithQueryText:(NSString *)queryText {
    self.currentSearchText = queryText;

    //Track the queries on a serial queue.  When a new operation comes in, cancel any outstanding operation
    //Another possible way of solving this would be to subclass NSOperation to add an AsyncBlockOperation
    //Additionally, it may be worthwhile to cancel the current running operation
    [self.searchOperationQueue cancelAllOperations];
    [self.searchOperationQueue addOperationWithBlock:^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        [self.etsyClient getListingsWithQueryText:queryText completion:^(RDEtsyClientSearchResult *searchResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Clear the cache whenever we search for new text
                [self.imageCache clearCache];
                self.searchResult = searchResult;
                [self.tableView reloadData];
                dispatch_semaphore_signal(sema);
            });
        }];
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performSearchForSearchController) object:nil];
    [self performSelector:@selector(performSearchForSearchController) withObject:nil afterDelay:0.3];
}

- (void)performSearchForSearchController {
    NSString *searchText;
    
    if([self.searchController.searchBar.text isEqualToString:@""]) {
        searchText = DefaultSearchTerm;
    } else {
        searchText = self.searchController.searchBar.text;
    }
    if(![self.currentSearchText isEqualToString:searchText]) {
        [self loadDataWithQueryText:searchText];
    }
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    if(indexPath) {
        RDEtsySearchResultItem *searchResultItem = [self searchResultItemAtIndexPath:indexPath];
        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:searchResultItem.listingURL];
        
        return safariViewController;
    }
    return nil;

}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}


@end
