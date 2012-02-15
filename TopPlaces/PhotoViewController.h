//
//  PhotoViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/27/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController
@property (nonatomic, strong) NSDictionary *photo;
@property (nonatomic, strong) Photo *photoFromDocument;
@end