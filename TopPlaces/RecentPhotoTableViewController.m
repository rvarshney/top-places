//
//  RecentPhotoTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "RecentPhotoTableViewController.h"
#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "MapViewController.h"
#import "FlickrMapAnnotation.h"

@interface RecentPhotoTableViewController() <MapViewControllerDelegate>
@end

@implementation RecentPhotoTableViewController
@synthesize recentPhotos = _recentPhotos;

- (NSArray *)mapAnnotations
{
    // Returns a list of map annotations for the recent photos
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.recentPhotos count]];
    for (NSDictionary *photos in self.recentPhotos) {
        [annotations addObject:[FlickrMapAnnotation annotationForDictionary:photos type:FlickrPhotoMapAnnotation]];
    }
    return annotations;
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    // Fetch the Flickr thumbnail
    // This method runs in an asynchronous task started in the map view
    FlickrMapAnnotation *mapAnnotation = (FlickrMapAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:mapAnnotation.dictionary format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (UIViewController *)mapViewController:(MapViewController *)sender destinationForAnnotation:(id<MKAnnotation>)annotation
{
    PhotoViewController * photoViewController;
    NSDictionary *photo = ((FlickrMapAnnotation *)annotation).dictionary;
    // Return a new photo view controller for the photo selected in the map callout
    photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [photoViewController setPhoto:photo];
    return photoViewController;
}

#pragma mark - Others

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Set the photo for the PhotoViewController
    if ([segue.identifier isEqualToString:@"Show Recent Photo"]) {
        int selectedRow = [[self.tableView indexPathForSelectedRow] row];
        [segue.destinationViewController setPhoto:[self.recentPhotos objectAtIndex:selectedRow]];
    } else if([segue.identifier isEqualToString:@"Show Recent Map"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

- (void)setRecentPhotos:(NSArray *)recentPhotos
{
    if (_recentPhotos != recentPhotos) {
        _recentPhotos = recentPhotos;
        [self.tableView reloadData];
    }   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Retrieve recent photos from NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.recentPhotos = (NSArray *)[defaults objectForKey:@"Recent"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentPhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    id photo = [self.recentPhotos objectAtIndex:indexPath.row];
    NSString *photoTitle = [(NSDictionary *)photo valueForKeyPath:FLICKR_PHOTO_TITLE];

    if (photoTitle == nil || [photoTitle isEqualToString:@""]) {
        photoTitle = @"Unknown";
    } 
    
    // Configure the cell
    cell.textLabel.text = photoTitle;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Recent Table Thumbnail Downloader", NULL);
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
