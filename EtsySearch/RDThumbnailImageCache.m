//
//  RDThumbnailImageCache.m
//  EtsySearch
//
//  Created by Robert Day on 4/6/16.
//  Copyright © 2016 Robert Day. All rights reserved.
//

#import "RDThumbnailImageCache.h"
@interface RDThumbnailImageCache ()
// TODO: Comment on LRU
@property (nonatomic, strong) NSCache *cache;
@end

@implementation RDThumbnailImageCache

- (instancetype)init {
    self = [super init];
    if(self) {
        _cache = [[NSCache alloc] init];
    
    }
    return self;
}

- (void)imageForURL:(NSURL *)url completion:(void (^)(UIImage *))completion {
    UIImage *image = [self.cache objectForKey:url];
    if(image) {
        return completion(image);
    } else {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(error) {
                NSLog(@"Error downloading image at url: %@, error: %@", url, error);
                return completion(nil);
            }
            if(!data) {
                return completion(nil);
            }
            
            UIImage *generatedImage = [UIImage imageWithData:data];
            if(generatedImage) {
                [self.cache setObject:generatedImage forKey:url];
            }
            return completion(generatedImage);
            
        }];
        [dataTask resume];
    }
}

- (void)clearCache {
    [self.cache removeAllObjects];
}

- (BOOL)containsImageForURL:(NSURL *)url {
    return [self.cache objectForKey:url] != nil;
}
@end
