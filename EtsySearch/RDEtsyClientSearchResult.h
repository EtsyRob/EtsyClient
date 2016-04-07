//
//  RDEtsySearchResult.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDEtsySearchResultItem;

@interface RDEtsyClientSearchResult : NSObject

@property (nonatomic, strong, readonly) NSArray<RDEtsySearchResultItem*> *results;
@property (nonatomic, strong, readonly) NSURL *searchURL;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, assign, readonly) NSInteger nextPage;

- (instancetype)initWithResults:(NSArray *)results currentPage:(NSInteger)currentPage nextPage:(NSInteger)nextPage searchURL:(NSURL *)searchURL;

@end
 