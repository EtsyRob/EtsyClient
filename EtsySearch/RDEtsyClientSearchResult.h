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

@property(nonatomic, strong) NSArray<RDEtsySearchResultItem*> *results;
@property (nonatomic, strong) NSURL *searchURL;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger nextPage;


- (instancetype)initWithResults:(NSArray *)results currentPage:(NSInteger)currentPage nextPage:(NSInteger)nextPage searchURL:(NSURL *)searchURL;

@end
 