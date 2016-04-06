//
//  RDEtsySearchResultParser.h
//  EtsySearch
//
//  Created by Robert Day on 4/5/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RDEtsyClientSearchResult;
@interface RDEtsySearchResultParser : NSObject

+ (RDEtsyClientSearchResult *)parseResponseData:(NSData *)responseData forSearchURL:(NSURL *)searchURL;
@end
