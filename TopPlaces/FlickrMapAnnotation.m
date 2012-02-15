//
//  FlickrMapAnnotation.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "FlickrMapAnnotation.h"
#import "FlickrFetcher.h"

@implementation FlickrMapAnnotation

@synthesize dictionary = _dictionary;
@synthesize type = _type;

+ (FlickrMapAnnotation *)annotationForDictionary:(NSDictionary *)dictionary type:(FlickrMapAnnotationType)type
{
    FlickrMapAnnotation *annotation = [[FlickrMapAnnotation alloc] init];
    annotation.dictionary = dictionary;
    annotation.type = type;
    return annotation;
}

#pragma mark - MKAnnotation

- (NSString *)title
{
    NSString *title;
    // Set the title based on the type of annotation
    switch (self.type) {
        case FlickrPlaceMapAnnotation:
            title = [self.dictionary valueForKeyPath:FLICKR_PLACE_NAME];
            NSRange range = [title rangeOfString:@", "];
            title = [title substringToIndex:range.location];
            break;
            
        case FlickrPhotoMapAnnotation:
            title = [self.dictionary valueForKey:FLICKR_PHOTO_TITLE];
            if (title == nil) title = @"Unknown";
            break;
        
        default:
            break;
    }
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle;
    // Set the subtitle based on the type of annotation
    switch (self.type) {
        case FlickrPlaceMapAnnotation:
            subtitle = [self.dictionary valueForKeyPath:FLICKR_PLACE_NAME];
            NSRange range = [subtitle rangeOfString:@", "];
            subtitle = [subtitle substringFromIndex:range.location + 2];
            break;
            
        case FlickrPhotoMapAnnotation:
            subtitle = [self.dictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
            break;
            
        default:
            break;
    }
    return subtitle;
}

- (CLLocationCoordinate2D)coordinate
{
    // Return the coordinates for the annotation
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.dictionary objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.dictionary objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
