//
//  FlickrPhotoCache.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/8/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoCache : NSObject
+ (FlickrPhotoCache *)instance;     // Shared instance of the cache (only accessed from the main thread at all times)
- (NSData *)getCachedFlickrPhoto:(NSString *)photoId;   // Key for the cache value
- (BOOL)addFlickrPhotoToCache:(NSString *)photoId withData:(NSData *)data;  // NSData for the photoId
@end
