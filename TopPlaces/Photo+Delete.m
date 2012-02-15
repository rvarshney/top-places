//
//  Photo+Delete.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Photo+Delete.h"
#import "Place.h"
#import "Tag.h"

@implementation Photo (Delete)

- (void)prepareForDeletion
{
    // Release related place and tag objects
    
    Place *place = self.takenAt;
    if ([place.photos count] == 1) {
        [self.managedObjectContext deleteObject:place];
    }
    
    NSSet *tags = self.taggedAs;
    for (Tag *tag in tags) {
        tag.photoCount = [NSNumber numberWithInt:[tag.photoCount intValue] - 1];
        if ([tag.photos count] == 1) {
            [self.managedObjectContext deleteObject:tag];
        }
    }
}

@end
