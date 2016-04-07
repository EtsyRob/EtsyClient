//
//  RDEtsySearchResultParser.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//
#import "RDEtsySearchResultItem.h"
#import "RDEtsySearchResultParser.h"
#import "RDEtsyClientSearchResult.h"



@implementation RDEtsySearchResultParser

#pragma mark - Public Methods
+ (RDEtsyClientSearchResult *)parseResponseData:(NSData *)responseData forSearchURL:(NSURL *)searchURL {
    
    if(!responseData) {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    if(error) {
        NSLog(@"Error parsing json data: %@", error);
        return nil;
    }
    
    NSArray *resultItems = resultDict[@"results"];
    
    NSArray *parsedResultItems = [self resultItemsForResultArray:resultItems];
    
    
    NSDictionary *paginationInfo = resultDict[@"pagination"];
    
    NSInteger effectivePage = [paginationInfo[@"effective_page"] integerValue];
    
    NSInteger nextPage = (paginationInfo[@"next_page"] == [NSNull null] ? -1 : [paginationInfo[@"next_page"] integerValue]);
    
    RDEtsyClientSearchResult *searchResult = [[RDEtsyClientSearchResult alloc] initWithResults:parsedResultItems currentPage:effectivePage nextPage:nextPage searchURL:searchURL];
    
    
    return searchResult;
}


#pragma mark - Private Methods
+ (NSArray *)resultItemsForResultArray:(NSArray *)resultArray {
    NSMutableArray *resultItems = [[NSMutableArray alloc] init];
    
    for(NSDictionary *itemDict in resultArray) {

        NSString *title = itemDict[@"title"];
        NSNumber *listingID = itemDict[@"listing_id"];
        NSString *description = itemDict[@"description"];
        NSString *listingURLString = itemDict[@"url"];
        NSURL *listingURL = [NSURL URLWithString:listingURLString];
        
        //Extract image
        NSDictionary *mainImage = itemDict[@"MainImage"];
        NSString *imageURLString = mainImage[@"url_75x75"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        
        RDEtsySearchResultItem *item = [[RDEtsySearchResultItem alloc] initWithListingID:listingID.integerValue title:title itemDescription:description listingURL: listingURL imageURL:imageURL];
        
        if(item) {
            [resultItems addObject:item];
        }
    }
    
    
    return [resultItems copy];
}
@end
