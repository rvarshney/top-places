//
//  Photo+Flickr.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Place+Create.h"
#import "Tag+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoInDocumentWithFlickrId:(NSString *)flickrId inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", flickrId];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        NSLog(@"Multiple photos with same name");
    } else if ([matches count] == 1) {
        photo = [matches lastObject];
    }
    
    return photo;
}

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = [self photoInDocumentWithFlickrId:[flickrInfo objectForKey:FLICKR_PHOTO_ID] inManagedObjectContext:context];
    
    if (photo == nil) {
        // The photo does not already exist in the database
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.identifier = [flickrInfo valueForKey:FLICKR_PHOTO_ID];
       
        NSString *photoTitle = [flickrInfo valueForKey:FLICKR_PHOTO_TITLE];
        NSString *photoDescription = [flickrInfo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        
        if (photoTitle == nil || [photoTitle isEqualToString:@""]) {
            if (photoDescription == nil || [photoDescription isEqualToString:@""]) {
                photo.title = @"Unknown";
            } else {
                photo.title = photoDescription;
            }
        } else {
            photo.title = photoTitle;
            photo.subtitle = photoDescription;
        }
        
        photo.photoURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge] absoluteString];
        photo.takenAt = [Place placeWithName:[flickrInfo valueForKey:FLICKR_PHOTO_PLACE_NAME] inManagedObjectContext:context];
        
        NSArray *tags = [[flickrInfo valueForKey:FLICKR_TAGS] componentsSeparatedByString:@" "];
        NSMutableSet *tagSet = [[NSMutableSet alloc] init];
        for (NSString *tag in tags) {
            NSString *newTag = [tag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![newTag isEqualToString:@""] && [newTag rangeOfString:@":"].location == NSNotFound) {
                newTag = [newTag stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[newTag substringToIndex:1] uppercaseString]];
                [tagSet addObject:[Tag tagWithName:newTag inManagedObjectContext:context]];
            }
        }
        photo.taggedAs = tagSet;
    } 
    
    return photo;
}

@end
