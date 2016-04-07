//
//  RDEtsyClient.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsyClient.h"
#import "RDEtsySearchResultParser.h"
#import "RDEtsyClientSearchResult.h"

@interface RDEtsyClient ()

@property (nonatomic, copy) NSString *apiKey;

@end

@implementation RDEtsyClient

#pragma mark - Lifecycle Methods

- (instancetype)initWithApiKey:(NSString *)apiKey {
    if(!apiKey) {
        return nil;
    }
    self = [super init];
    if(self) {
        _apiKey = apiKey;
    }
    return self;
}

#pragma mark - Public Methods

- (void)getListingsWithQueryText:(NSString *)queryText completion:(void (^)(RDEtsyClientSearchResult *))completion {
    if(!queryText) {
        return completion(nil);
    }
    
    NSURL *searchURL = [self listingURLForQueryText:queryText];
    [self getListingsWithURL:searchURL completion:completion];
    
}

- (void)getMoreListingsWithSearchResult:(RDEtsyClientSearchResult *)searchResult completion:(void (^)(RDEtsyClientSearchResult *))completion {
    NSURL *searchURL = [self listingURLForNextPageWithSearchResult:searchResult];
    if(!searchURL) {
        return completion(nil);
    }
    [self getListingsWithURL:searchURL completion:completion];
    
}

#pragma mark - Private Methods

- (void)getListingsWithURL:(NSURL *)url completion:(void (^)(RDEtsyClientSearchResult *))completion {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            NSLog(@"Error getting listings with URL: %@, error: %@", url, error);
            return completion(nil);
        }
        if([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if(![self isValidResponseCode:httpResponse]) {
                NSLog(@"Invalid response returned while getting listings with URL: %@, responseCode: %ld", url, (long)httpResponse.statusCode);
                return completion(nil);
            }
        }
        if(!data) {
            NSLog(@"No data returned while gettings listings with URL: %@", url);
            return completion(nil);
        }
        
        RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:data forSearchURL:url];
        
        return completion(searchResult);
        
        
    }];
    
    [dataTask resume];
    
}

- (NSURL *)listingURLForQueryText:(NSString *)queryText page:(NSNumber *)page {
    
    NSString *escapedSearch = [queryText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.etsy.com/v2/listings/active?api_key=%@&includes=MainImage&keywords=%@", self.apiKey, escapedSearch];
    if(page) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&page=%d", page.intValue]];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    return url;
    
}
- (NSURL *)listingURLForQueryText:(NSString *)queryText {
    return [self listingURLForQueryText:queryText page:nil];
}

- (NSURL *)listingURLForNextPageWithSearchResult:(RDEtsyClientSearchResult *)searchResult {
    NSInteger nextPage = searchResult.nextPage;
    if(nextPage == -1) {
        return nil;
    }
    NSURL *previousSearchURL = searchResult.searchURL;
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:previousSearchURL resolvingAgainstBaseURL:NO];
    
    NSMutableArray *queryItems = [[urlComponents queryItems] mutableCopy];
    NSString *nextPageString = [NSString stringWithFormat:@"%ld", (long)nextPage];
    
    NSURLQueryItem *nextPageQueryItem = [NSURLQueryItem queryItemWithName:@"page" value:nextPageString];
    
    BOOL foundPage = NO;
    //Swap the page query item with the next page
    for(NSInteger i = 0; i < queryItems.count; i++) {
        NSURLQueryItem *queryItem = queryItems[i];
        if([queryItem.name isEqualToString:@"page"]) {
            foundPage = YES;
            queryItems[i] = nextPageQueryItem;
            break;
        }
        
    }
    if(!foundPage) {
        [queryItems addObject:nextPageQueryItem];
    }
    
    
    urlComponents.queryItems = queryItems;
    NSURL *url = [urlComponents URL];
    
    return url;
    
}

- (BOOL)isValidResponseCode:(NSHTTPURLResponse *)response {
    return (response.statusCode >= 200 && response.statusCode < 300);
}

@end
