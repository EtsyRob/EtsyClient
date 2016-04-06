//
//  RDEtsyListingTableViewController.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsyListingTableViewController.h"
#import "RDEtsyClientSearchResult.h"
#import "RDEtsySearchResultItem.h"
#import "RDEtsyClient.h"
#import "RDEtsyListingTableViewCell.h"
#import "UIColor+Hex.h"

static NSString *cellIdentifier = @"basicCellIdentifier";
static NSString *apiKey = @"liwecjs0c3ssk6let4p1wqt9";
static NSString *defaultSearchTerm = @"Wooden Chairs";

@interface RDEtsyClientSearchResult(Backfill)
- (void)backfillResultsFromSearchResult:(RDEtsyClientSearchResult *)searchResult;
@end

@implementation RDEtsyClientSearchResult(Backfill)

- (void)backfillResultsFromSearchResult:(RDEtsyClientSearchResult *)searchResult {
    NSArray *newResults = [searchResult.results arrayByAddingObjectsFromArray:self.results];
    self.results = newResults;
}

@end



@interface RDEtsyListingTableViewController () <UISearchBarDelegate>
@property (nonatomic, strong) RDEtsyClientSearchResult *searchResult;
@property (nonatomic, strong) RDEtsyClient *etsyClient;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic) BOOL updating;


@end

@implementation RDEtsyListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.etsyClient = [[RDEtsyClient alloc] initWithApiKey:apiKey];
    [self loadDataWithQueryText:defaultSearchTerm];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationController.navigationBarHidden = NO;
    [self applyTheme];
    self.searchBar.delegate = self;

    
    // Do any additional setup after loading the view.
}


- (void)applyTheme {
    self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexString:@"34A8C4"];

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)loadDataWithQueryText:(NSString *)queryText {
    [self.etsyClient getListingsWithQueryText:queryText completion:^(RDEtsyClientSearchResult *searchResult) {
        if(searchResult) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //TODO: Merge results
                self.searchResult = searchResult;
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)loadMoreResults {
    if(self.updating) {
        NSLog(@"Skipping loading more results, already updating...");
    } else {
        //TODO: Do I have to sync this?
        self.updating = YES;
        [self.etsyClient getMoreListingsWithSearchResult:self.searchResult completion:^(RDEtsyClientSearchResult *searchResult) {
            
            //TODO: Need to lock on touching the searchResult array
            [searchResult backfillResultsFromSearchResult:self.searchResult];
            self.searchResult = searchResult;
            dispatch_async(dispatch_get_main_queue(), ^{
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

- (void)configureCell:(RDEtsyListingTableViewCell *)cell forSearchResultItem:(RDEtsySearchResultItem *)searchResultItem {
    cell.listingTitle.text = searchResultItem.title;
    cell.imageView.image = nil;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    if (searchResultItem.imageURL) {
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:searchResultItem.imageURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.imageView.image = [UIImage imageWithData:data];
                    [cell setNeedsLayout];
                });
            }
        }];
        
        [dataTask resume];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    RDEtsySearchResultItem *searchResultItem = [self searchResultItemAtIndexPath:indexPath];
    if([cell isKindOfClass:[RDEtsyListingTableViewCell class]]) {
        RDEtsyListingTableViewCell *listingTableViewCell = (RDEtsyListingTableViewCell *)cell;
        [self configureCell:listingTableViewCell forSearchResultItem:searchResultItem];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Move the 8 into a var
    if((self.searchResult.results.count - indexPath.row) <= 8) {
        [self loadMoreResults];
    }
}


#pragma mark - UISearchBarDelegate

//If the user clears the search bar, bring back the default text
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if([searchText isEqualToString:@""]) {
        [self loadDataWithQueryText:defaultSearchTerm];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchText;
    if([searchBar.text isEqualToString:@""]) {
        searchText = defaultSearchTerm;
    } else {
        searchText = searchBar.text;
    }
    [self loadDataWithQueryText:searchText];
}




@end
