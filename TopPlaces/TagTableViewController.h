//
//  TagTableViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@interface TagTableViewController : CoreDataTableViewController <UISearchBarDelegate>

@property (nonatomic, strong) NSString *vacationName;

@end
