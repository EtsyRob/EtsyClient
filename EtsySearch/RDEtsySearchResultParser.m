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


+ (RDEtsyClientSearchResult *)parseResponseData:(NSData *)responseData forSearchURL:(NSURL *)searchURL {
    
    if(!responseData) {
        return nil;
    }
    
    // Sanity checks
    
    //TODO: Handle errors
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
    
    if(!resultDict || ![resultDict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSArray *resultItems = resultDict[@"results"];
    if(!resultItems || ![resultItems isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSArray *parsedResultItems = [self resultItemsForResultArray:resultItems];
    
    
    NSDictionary *paginationInfo = resultDict[@"pagination"];
    
    NSInteger effectivePage = [paginationInfo[@"effective_page"] integerValue];
    NSInteger nextPage = [paginationInfo[@"next_page"] integerValue];
    
    RDEtsyClientSearchResult *searchResult = [[RDEtsyClientSearchResult alloc] initWithResults:parsedResultItems currentPage:effectivePage nextPage:nextPage searchURL:searchURL];
    
    
    return searchResult;
}

//TODO: Perhaps move keys into variables?
+ (NSArray *)resultItemsForResultArray:(NSArray *)resultArray {
    NSMutableArray *resultItems = [[NSMutableArray alloc] init];
    
    for(NSDictionary *itemDict in resultArray) {
        if(![itemDict isKindOfClass:[NSDictionary class]]) {
            //If there is a malformed individual search result, continue
            continue;
        }
        
        //TODO: Sanity check this data
        NSString *title = itemDict[@"title"];
        NSNumber *listingID = itemDict[@"listing_id"];
        NSString *description = itemDict[@"description"];
        
        //Extract image
        NSDictionary *mainImage = itemDict[@"MainImage"];
        NSString *imageURLString = mainImage[@"url_75x75"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        
        //TODO: Convert to NSInteger
        RDEtsySearchResultItem *item = [[RDEtsySearchResultItem alloc] initWithListingID:listingID.intValue title:title itemDescription:description imageURL:imageURL];
        
        if(item) {
            [resultItems addObject:item];
        }
    }
    
    
    return [resultItems copy];
}
@end
