//
//  RDEtsyClientSearchResult+Backfill.m
//  EtsySearch
//
//  Created by Robert Day on 4/6/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsyClientSearchResult+Backfill.h"

@implementation RDEtsyClientSearchResult(Backfill)

+ (RDEtsyClientSearchResult *)searchResultByPrependingSearchResult:(RDEtsyClientSearchResult *)fromSearchResult intoSearchResult:(RDEtsyClientSearchResult *)intoSearchResult {
    
    NSArray *newResults = [fromSearchResult.results arrayByAddingObjectsFromArray:intoSearchResult.results];
    
    RDEtsyClientSearchResult *newSearchResult = [[RDEtsyClientSearchResult alloc] initWithResults:newResults currentPage:intoSearchResult.currentPage nextPage:intoSearchResult.nextPage searchURL:intoSearchResult.searchURL];
    return newSearchResult;
}

@end
