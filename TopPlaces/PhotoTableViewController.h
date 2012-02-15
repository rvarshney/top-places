//
//  PhotoTableViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/26/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewController : UITableViewController
@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photosInPlace; // Flickr photos for the place
@end
