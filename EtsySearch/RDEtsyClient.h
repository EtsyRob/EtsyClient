//
//  RDEtsyClient.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDEtsyClientSearchResult;

static NSInteger NoNextPageValue = -1;

@interface RDEtsyClient : NSObject

- (instancetype)initWithApiKey:(NSString *)apiKey;
- (void)getListingsWithQueryText:(NSString *)queryText completion:(void (^)(RDEtsyClientSearchResult *))completion;
- (void)getMoreListingsWithSearchResult:(RDEtsyClientSearchResult *)searchResult completion:(void (^)(RDEtsyClientSearchResult *))completion;

@end
