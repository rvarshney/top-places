//
//  Place+Create.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Place+Create.h"

@implementation Place (Create)

+ (Place *)placeWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Place *place = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *places = [context executeFetchRequest:request error:&error];
    
    if (!places || ([places count] > 1)) {
        NSLog(@"Multiple places with same name");
    } else if (![places count]) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = name;
        place.visitedOn = [NSDate date];
    } else {
        place = [places lastObject];
    }
    
    return place;
}

@end
