//
//  MapViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation;
- (UIViewController *)mapViewController:(MapViewController *)sender destinationForAnnotation:(id<MKAnnotation>)annotation; // Obtains the destination view from the delegate
@end

@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@end
