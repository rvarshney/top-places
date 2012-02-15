//
//  TopPlacesTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/25/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "TopPlacesTableViewController.h"
#import "PhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "MapViewController.h"
#import "FlickrMapAnnotation.h"

@interface TopPlacesTableViewController() <MapViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapButton;
@property (nonatomic, strong) NSDictionary *placesByCountry;
@end

@implementation TopPlacesTableViewController
@synthesize topPlaces = _topPlaces;
@synthesize mapButton = _mapButton;
@synthesize placesByCountry = _placesByCountry;

- (void)updatePlacesByCity
{
    // Dictionary to store all the places as an array for a given country
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in self.topPlaces) {
        NSString *placeName = [place valueForKeyPath:FLICKR_PLACE_NAME];
        NSRange range = [placeName rangeOfString:@", " options:NSBackwardsSearch];
        NSString *country = [placeName substringFromIndex:range.location + 2];
        NSMutableArray *places = [placesByCountry objectForKey:country];
        if (places == nil) {
            places = [NSMutableArray array];
            [placesByCountry setObject:places forKey:country];
        }
        [places addObject:place];
    }
    self.placesByCountry = placesByCountry;
}

- (NSArray *)mapAnnotations
{
    // Return a list of map annotations for the top places to show on the map view
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.topPlaces count]];
    for (NSDictionary *place in self.topPlaces) {
        [annotations addObject:[FlickrMapAnnotation annotationForDictionary:place type:FlickrPlaceMapAnnotation]];
    }
    return annotations;
}

- (void)setTopPlaces:(NSArray *)topPlaces
{
    if (_topPlaces != topPlaces) {
        _topPlaces = topPlaces;
        // Update the dictionary
        [self updatePlacesByCity];
        [self.tableView reloadData];
    }       
}

- (IBAction)refresh:(UIBarButtonItem *)sender 
{
    // Set activity indicator view and network activity indicator view
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.leftBarButtonItem = nil;
    
    // Make async call to download the top places from Flickr
    dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Places Downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem = self.mapButton;
            self.navigationItem.leftBarButtonItem = sender;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            self.topPlaces = places;
        });
    });
    dispatch_release(downloadQueue);
}

#pragma mark - MapViewControllerDelegate

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation
{
    // None of the places have images associated with them, so return nil 
    // for the map annotation callouts
    return nil;
}

- (UIViewController *)mapViewController:(MapViewController *)sender destinationForAnnotation:(id<MKAnnotation>)annotation
{
    // Returns the view with photo list for the selected place annotation to 
    // the map view to push on the navigation controller stack
    PhotoTableViewController *photoTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoTableViewController"];
    [photoTableViewController setPlace:((FlickrMapAnnotation *)annotation).dictionary];
    return photoTableViewController;
}

#pragma mark - UITableView

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.topPlaces == nil) {
        [self refresh:self.navigationItem.leftBarButtonItem];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource


- (NSString *)countryForSection:(NSInteger)section
{
    return [[self.placesByCountry allKeys] objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self countryForSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.placesByCountry count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *country = [self countryForSection:section];
    NSArray *placesByCountry = [self.placesByCountry objectForKey:country];
    return [placesByCountry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    // Configure the cell
    NSString *country = [self countryForSection:indexPath.section];
    NSArray *placesByCountry = [self.placesByCountry objectForKey:country];
    NSDictionary *place = [placesByCountry objectAtIndex:indexPath.row];
    
    // String split to extract the city name
    NSString *placeName = [(NSDictionary *)place valueForKeyPath:FLICKR_PLACE_NAME];
    NSRange range = [placeName rangeOfString:@", "];
    
    cell.textLabel.text = [placeName substringToIndex:range.location];
    cell.detailTextLabel.text = [placeName substringFromIndex:range.location + 2];

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo List"]) {
        // Determine which place was selected
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *country = [self countryForSection:indexPath.section];
        NSArray *placesByCountry = [self.placesByCountry objectForKey:country];
        NSDictionary *place = [placesByCountry objectAtIndex:indexPath.row];
        // Set the place in the PhotoTableViewController
        [segue.destinationViewController setPlace:place];
    } else if([segue.identifier isEqualToString:@"Show Place Map"]) {
        [segue.destinationViewController setDelegate:self];
        [segue.destinationViewController setAnnotations:[self mapAnnotations]];
    }
}

- (void)viewDidUnload {
    [self setMapButton:nil];
    [super viewDidUnload];
}
@end
