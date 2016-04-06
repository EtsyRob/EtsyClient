//
//  RDEtsySearchResultItem.m
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDEtsySearchResultItem.h"

@implementation RDEtsySearchResultItem


- (instancetype)initWithListingID:(int)listingID title:(NSString *)title itemDescription:(NSString *)itemDescription imageURL:(NSURL *)imageURL {
    self = [super init];
    if(self) {
        _listing_id = listingID;
        _title = title;
        _itemDescription = itemDescription;
        _imageURL = imageURL;
    }
    
    return self;
}

@end
