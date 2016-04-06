//
//  RDThumbnailImageCache.h
//  EtsySearch
//
//  Created by Robert Day on 4/6/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RDThumbnailImageCache : NSObject

-(instancetype)init;

-(void)imageForURL:(NSURL *)url completion:(void (^)(UIImage *))completion;
-(void)clearCache;
@end
