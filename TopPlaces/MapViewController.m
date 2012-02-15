//
//  MapViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController() <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *mapType;
@property (strong, nonatomic) id<MKAnnotation> latestAnnotation;
@end

#define MAP_PADDING 1.05

@implementation MapViewController

@synthesize mapView = _mapView;
@synthesize mapType = _mapType;
@synthesize annotations = _annotations;
@synthesize latestAnnotation = _latestAnnotation;
@synthesize delegate = _delegate;

#pragma mark - Synchronization

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) {
        [self.mapView addAnnotations:self.annotations];
        
        // Set up the initial zoom level of the map
        double highestLat = -90.00, highestLong = -180.00, lowestLat = 90.00, lowestLong = 180.00;
        for(id<MKAnnotation> annotation in self.annotations) {
            CLLocationCoordinate2D coordinate = [annotation coordinate];
            highestLat = MAX(highestLat, coordinate.latitude);
            lowestLat = MIN(lowestLat, coordinate.latitude);
            highestLong = MAX(highestLong, coordinate.longitude);
            lowestLong = MIN(lowestLong, coordinate.longitude);
        }
        
        MKCoordinateSpan span;
        // Add 5% padding around the map view
        span.latitudeDelta = (highestLat - lowestLat) * MAP_PADDING;
        span.longitudeDelta = (highestLong - lowestLong) * MAP_PADDING;
        
        CLLocationCoordinate2D center;
        center.latitude = lowestLat + (highestLat - lowestLat) / 2;
        center.longitude = lowestLong + (highestLong - lowestLong) / 2;
        
        MKCoordinateRegion region;
        region.span = span;
        region.center = center;
        
        [self.mapView setRegion:region];
    }
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Map"];
    if (!pinView) {
        // Set up the view for the callout
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Map"];
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

    pinView.annotation = annotation;
    [(UIImageView *)pinView.leftCalloutAccessoryView setImage:nil];
    
    return pinView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)pinView
{
    self.latestAnnotation = pinView.annotation;
    
    // Fetch the thumbnails in a different thread so as to avoid blocking the main thread
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Thumbnail Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        id<MKAnnotation> fetchedAnnotation = pinView.annotation;
        UIImage *image = [self.delegate mapViewController:self imageForAnnotation:pinView.annotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            // If the latest annotation and the fetched annotation do not match
            // discard the fetched annotation image
            if (self.latestAnnotation == fetchedAnnotation) {
                if (image != nil) {
                    pinView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                    [(UIImageView *)pinView.leftCalloutAccessoryView setImage:image];
                } else {
                    pinView.leftCalloutAccessoryView = nil;
                }
            }
        });
    });
    dispatch_release(downloadQueue);
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // Retrieve the destination view controller from the delegate
    UIViewController *destinationViewController = [self.delegate mapViewController:self destinationForAnnotation:view.annotation];
    if (destinationViewController != nil && self.navigationController) {
        [self.navigationController pushViewController:destinationViewController animated:YES];
    }
}

#pragma mark - UIViewController

- (void)changeMapType:(UISegmentedControl *)sender
{   
    // Set the map type based on the element selected in the segmented control
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.mapView setMapType:MKMapTypeStandard];
            break;
        case 1:
            [self.mapView setMapType:MKMapTypeSatellite];
            break;
        case 2:
            [self.mapView setMapType:MKMapTypeHybrid];
            break;
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    self.mapType.selectedSegmentIndex = 0;
    // Segment change event listener on the segmented view to change the map type
    [self.mapType addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [self setMapType:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
