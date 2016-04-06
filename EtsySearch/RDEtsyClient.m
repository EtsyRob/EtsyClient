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


//TODO: Return nil if no apiKey
- (instancetype)initWithApiKey:(NSString *)apiKey {
    self = [super init];
    if(self) {
        _apiKey = apiKey;
    }
    return self;
}

- (NSURL *)listingURLForQueryText:(NSString *)queryText page:(NSNumber *)page {
    //    https://api.etsy.com/v2/listings/active?api_key=liwecjs0c3ssk6let4p1wqt9&includes=MainImage&keywords=chair&page=2
    
    NSString *escapedSearch = [queryText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    //TODO: Come back and use NSURLComponents
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
    NSURL *previousSearchURL = searchResult.searchURL;
    
    NSInteger nextPage = searchResult.nextPage;
    
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:previousSearchURL resolvingAgainstBaseURL:NO];
    
    //TODO: Need to create query item if it doesn't exist
    NSMutableArray *queryItems = [[urlComponents queryItems] mutableCopy];
    
    //TODO: What is the expected behavior if page already exists?
    [queryItems addObject:[NSURLQueryItem queryItemWithName:@"page" value:[NSString stringWithFormat:@"%ld", (long)nextPage]]];
    
    urlComponents.queryItems = queryItems;
    NSURL *url = [urlComponents URL];
    
    return url;
    
}

- (BOOL)isValidResponseCode:(NSHTTPURLResponse *)response {
    return (response.statusCode >= 200 && response.statusCode < 300);
}

- (void)getListingsWithURL:(NSURL *)url completion:(void (^)(RDEtsyClientSearchResult *))completion {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error) {
            //TODO: Log error
            return completion(nil);
        }
        if(![self isValidResponseCode:response]) {
            //TODO: Log error
            return completion(nil);
        }
        if(!data) {
            //TODO: Log error
            return completion(nil);
        }
        
        RDEtsyClientSearchResult *searchResult = [RDEtsySearchResultParser parseResponseData:data forSearchURL:url];
        
        return completion(searchResult);
        
        
    }];
    
    [dataTask resume];

}

- (void)getListingsWithQueryText:(NSString *)queryText completion:(void (^)(RDEtsyClientSearchResult *))completion {
    
    NSURL *searchURL = [self listingURLForQueryText:queryText];
    [self getListingsWithURL:searchURL completion:completion];
    
}

- (void)getMoreListingsWithSearchResult:(RDEtsyClientSearchResult *)searchResult completion:(void (^)(RDEtsyClientSearchResult *))completion {
    NSURL *searchURL = [self listingURLForNextPageWithSearchResult:searchResult];
    [self getListingsWithURL:searchURL completion:completion];
    
}


@end
