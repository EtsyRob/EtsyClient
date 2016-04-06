//
//  RDEtsySearchResult.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsyClientSearchResult.h"
@interface RDEtsyClientSearchResult ()


@end

@implementation RDEtsyClientSearchResult

- (instancetype)initWithResults:(NSArray *)results currentPage:(NSInteger)currentPage nextPage:(NSInteger)nextPage searchURL:(NSURL *)searchURL{
    if(!searchURL || !results) {
        return nil;
    }
    
    self = [super init];
    if(self) {
        _nextPage = nextPage;
        _currentPage = currentPage;
        _results = results;
        _searchURL = searchURL;
    }
    return self;
}

@end
