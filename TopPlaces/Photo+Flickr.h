//
//  Photo+Flickr.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Photo *)photoInDocumentWithFlickrId:(NSString *)flickrId inManagedObjectContext:(NSManagedObjectContext *)context;

@end
