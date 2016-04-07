//
//  RDEtsyClientSearchResult+Backfill.h
//  EtsySearch
//
//  Created by Robert Day on 4/6/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RDEtsyClientSearchResult.h"


@interface RDEtsyClientSearchResult(Backfill)
+ (RDEtsyClientSearchResult *)searchResultByPrependingSearchResult:(RDEtsyClientSearchResult *)fromSearchResult
                                                  intoSearchResult:(RDEtsyClientSearchResult *)intoSearchResult;
@end