//
//  PhotoTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/26/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "MapViewController.h"
#import "FlickrMapAnnotation.h"

#define MAX_PHOTOS 50

@interface PhotoTableViewController() <MapViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@end

@implementation PhotoTableViewController
@synthesize mapButton = _mapButton;
@synthesize place = _place;
@synthesize photosInPlace = _photosInPlace;

#pragma mark - Others

- (NSArray *)mapAnnotations
{
    // Return a list of photo annotations for the map view
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photosInPlace count]];
    for (NSDictionary *photos in self.photosInPlace) {
        [annotations addObject:[FlickrMapAnnotation annotationForDictionary:photos type:FlickrPhotoMapAnnotation]];
    }
    return annotations;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set the photo of the PhotoViewController
    if ([segue.identifier isEqualToString:@"Show Photo"]) {
        int selectedRow = [[self.tableView indexPathForSelectedRow] row];
        [segue.destinationViewController setPhoto:[self.photosInPlace objectAtIndex:selectedRow]];
    } else if([segue.identifier isEqualToString:@"Show Photo Map"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

- (void)setPlace:(NSDictionary *)place
{
    _place = place;
    
    // Extract the city name and set the title
    NSString *placeName = [(NSDictionary *)place valueForKeyPath:FLICKR_PLACE_NAME];
    NSRange range = [placeName rangeOfString:@", "];    
    self.title = [placeName substringToIndex:range.location];
}

- (void)setPhotosInPlace:(NSArray *)photosInPlace
{
    if (_photosInPlace != photosInPlace) {
        _photosInPlace = photosInPlace;
        [self.tableView reloadData];
    }
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    // Fetch the Flickr thumbnail for the annotation
    // This method is called asynchronously from the the map view
    FlickrMapAnnotation *mapAnnotation = (FlickrMapAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:mapAnnotation.dictionary format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (UIViewController *)mapViewController:(MapViewController *)sender destinationForAnnotation:(id<MKAnnotation>)annotation
{
    // Send back a new photo view controller to the map to push on the navigation
    // controller stack
    PhotoViewController * photoViewController;
    NSDictionary *photo = ((FlickrMapAnnotation *)annotation).dictionary;
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [photoViewController setPhoto:photo];
    return photoViewController;
}

#pragma mark - UITableView

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.photosInPlace == nil) {
        // Set the spinner while the async task downloads photos for the set place
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        // Fetch the list of photos for the set place
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Photos Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSArray *photosInPlace = [FlickrFetcher photosInPlace:self.place maxResults:MAX_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.rightBarButtonItem = self.mapButton;
                self.photosInPlace = photosInPlace;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        });
        dispatch_release(downloadQueue);
    }
}

- (void)viewDidUnload
{
    [self setMapButton:nil];
    [self setMapButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photosInPlace count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    id photo = [self.photosInPlace objectAtIndex:indexPath.row];
    NSString *photoTitle = [(NSDictionary *)photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSString *photoDescription = [(NSDictionary *)photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    NSString *textLabel;
    NSString *detailTextLabel;
    
    // If photo title is nil set it to the description, else set it to unknown
    if (photoTitle == nil || [photoTitle isEqualToString:@""]) {
        if (photoDescription == nil || [photoDescription isEqualToString:@""]) {
            textLabel = @"Unknown";
        } else {
            textLabel = photoDescription;
        }
    } else {
        textLabel = photoTitle;
        detailTextLabel = photoDescription;
    }
    
    // Configure the cell
    cell.textLabel.text = textLabel;
    cell.detailTextLabel.text = detailTextLabel;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Photo Table Thumbnail Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
        NSData *data = [NSData dataWithContentsOfURL:url];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                cell.imageView.image = [UIImage imageWithData:data];
                [cell setNeedsLayout];
            } else {
                cell.imageView.image = nil;
            }
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    dispatch_release(downloadQueue);
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set the image to nil before it is loaded by GCD
    cell.imageView.image = nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
