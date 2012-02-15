//
//  VacationPhotoTableViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Place.h"
#import "Tag.h"

@interface VacationPhotoTableViewController : CoreDataTableViewController

@property (nonatomic, strong) Place *place;
@property (nonatomic, strong) Tag *searchTag;
@property (nonatomic, strong) NSString *vacationName;

@end
