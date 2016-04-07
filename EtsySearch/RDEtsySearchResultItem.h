//
//  RDEtsySearchResultItem.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDEtsySearchResultItem : NSObject

@property (nonatomic, assign, readonly) NSInteger listing_id;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *itemDescription;
@property (nonatomic, strong, readonly) NSURL *listingURL;
@property (nonatomic, strong, readonly) NSURL *imageURL;


- (instancetype)initWithListingID:(NSInteger)listingID
                            title:(NSString *)title
                  itemDescription:(NSString *)itemDescription
                       listingURL:(NSURL *)listingURL
                         imageURL:(NSURL *)imageURL;
@end
