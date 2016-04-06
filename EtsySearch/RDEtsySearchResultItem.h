//
//  RDEtsySearchResultItem.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RDEtsySearchResultItem : NSObject

@property (nonatomic, assign) int listing_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *itemDescription;

//TODO: Will have multiple image URLs
@property (nonatomic, strong) NSURL *imageURL;



//TODO: What do write about the other fields that we're not supporting?
- (instancetype)initWithListingID:(int)listingID
                            title:(NSString *)title
                  itemDescription:(NSString *)itemDescription
                         imageURL:(NSURL *)imageURL;
@end
