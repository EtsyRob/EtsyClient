//
//  RDEtsySearchResultItem.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDEtsySearchResultItem : NSObject

@property (nonatomic, assign) NSInteger listing_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemDescription;
@property (nonatomic, strong) NSURL *listingURL;
@property (nonatomic, strong) NSURL *imageURL;



- (instancetype)initWithListingID:(NSInteger)listingID
                            title:(NSString *)title
                  itemDescription:(NSString *)itemDescription
                       listingURL:(NSURL *)listingURL
                         imageURL:(NSURL *)imageURL;
@end
