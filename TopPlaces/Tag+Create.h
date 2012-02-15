//
//  Tag+Create.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
