//
//  Tag+Create.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tag *tag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *tags = [context executeFetchRequest:request error:&error];
    
    if (!tags || ([tags count] > 1)) {
        NSLog(@"Multiple tags with same name");
    } else if (![tags count]) {
        tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        tag.name = name;
    } else {
        tag = [tags lastObject];
    }
    tag.photoCount = [NSNumber numberWithInt:[tag.photoCount intValue] + 1];
    return tag;
}

@end
