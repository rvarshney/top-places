//
//  FlickrMapAnnotation.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
	FlickrPhotoMapAnnotation = 1,
	FlickrPlaceMapAnnotation = 2
} FlickrMapAnnotationType; // Type for photo or place map annotation

@interface FlickrMapAnnotation : NSObject <MKAnnotation>
+ (FlickrMapAnnotation *)annotationForDictionary:(NSDictionary *)dictionary type:(FlickrMapAnnotationType) type;
@property (nonatomic, strong) NSDictionary *dictionary; // to store the photo or place dictionary
@property FlickrMapAnnotationType type;
@end
