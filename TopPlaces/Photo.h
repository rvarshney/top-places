//
//  Photo.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/19/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *taggedAs;
@property (nonatomic, retain) Place *takenAt;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addTaggedAsObject:(Tag *)value;
- (void)removeTaggedAsObject:(Tag *)value;
- (void)addTaggedAs:(NSSet *)values;
- (void)removeTaggedAs:(NSSet *)values;
@end
