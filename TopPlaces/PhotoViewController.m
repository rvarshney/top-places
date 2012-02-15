//
//  PhotoViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 10/27/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoCache.h"
#import "VacationHelper.h"
#import "Photo+Flickr.m"
#import "VacationTableViewController.h"

#define MAX_RECENT_PHOTOS 20
#define VISIT @"Visit"
#define UNVISIT @"Unvisit"

@interface PhotoViewController() <UIScrollViewDelegate, VacationTableViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *visitButton;
@property BOOL onVacation;
@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize visitButton = _visitButton;
@synthesize photo = _photo;
@synthesize photoFromDocument = _photoFromDocument;
@synthesize onVacation = _onVacation;

#pragma mark - UIViewController

- (void)updateUserDefaults
{
    // Store the photo in NSUserDefaults 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recentPhotos = [(NSArray *)[defaults objectForKey:@"Recent"] mutableCopy];
    if (recentPhotos == nil) {
        recentPhotos = [NSMutableArray array];
        [recentPhotos addObject:self.photo];
    } else {
        // Check that the total number of stored photos does not
        // exceed 20
        if (self.photo != nil) {
            [recentPhotos removeObject:self.photo];
            [recentPhotos insertObject:self.photo atIndex:0];
            if ([recentPhotos count] > MAX_RECENT_PHOTOS) {
                [recentPhotos removeLastObject];
            }
        }
    }
    [defaults setObject:[NSArray arrayWithArray:recentPhotos] forKey:@"Recent"];
    [defaults synchronize];
}

- (void)updateVisitButtonTitle
{
    self.visitButton.title = VISIT;

    NSArray *vacations = [VacationHelper listVacations];
    for (NSString *vacationName in vacations) {
        [VacationHelper openVacation:vacationName usingBlock:^(UIManagedDocument *vacation) {
            Photo *photo = [Photo photoInDocumentWithFlickrId:[self.photo valueForKey:FLICKR_PHOTO_ID] inManagedObjectContext:vacation.managedObjectContext];
            if (photo != nil) {
                self.visitButton.title = UNVISIT;
            }
        }];
    }    
}

- (void)setPhotoDataView:(NSData *)data
{
    self.imageView.image = [UIImage imageWithData:data];
    self.scrollView.delegate = self;
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    
    CGFloat widthScale = (self.scrollView.bounds.size.width / self.scrollView.contentSize.width);
    CGFloat heightScale = (self.scrollView.bounds.size.height / self.scrollView.contentSize.height);
    
    self.scrollView.minimumZoomScale = MIN(widthScale, heightScale);
    self.scrollView.maximumZoomScale = 5;
    self.scrollView.zoomScale = MAX(widthScale, heightScale);
}

- (void)updatePhotoView
{
    // Lookup the cache
    NSData *data = [[FlickrPhotoCache instance] getCachedFlickrPhoto:[self.photo valueForKey:FLICKR_PHOTO_ID]];
    if (data) {
        [self updateVisitButtonTitle];
        [self setPhotoDataView:data];
        self.navigationItem.title = [self.photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    } else {
        // Set the spinner while the photo is retrieved from Flickr
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        // Start async task to download the photo
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Photo Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSDictionary *fetchedPhoto = self.photo;
            NSURL *photoUrl = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            NSData *data = [[NSData alloc] initWithContentsOfURL:photoUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                // If the latest photo is not the same as the fetched photo
                // discard the fetched photo
                if (self.photo == fetchedPhoto) {
                    self.navigationItem.rightBarButtonItem = self.visitButton;
                    [self updateVisitButtonTitle];
                    // When photos are retrieved set the frame and scroll view zoom parameters
                    [self setPhotoDataView:data];
                    self.navigationItem.title = [self.photo valueForKeyPath:FLICKR_PHOTO_TITLE];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                // Add any fetched photo into cache
                [[FlickrPhotoCache instance] addFlickrPhotoToCache:[fetchedPhoto valueForKey:FLICKR_PHOTO_ID] withData:data];
            });
        });
        dispatch_release(downloadQueue);
    }
    
    // Update recent photos
    [self updateUserDefaults];
}

- (void)updatePhotoFromDocumentView
{
    // Lookup the cache
    NSData *data = [[FlickrPhotoCache instance] getCachedFlickrPhoto:self.photoFromDocument.identifier];
    if (data) {
        self.visitButton.title = UNVISIT;
        [self setPhotoDataView:data];
        self.navigationItem.title = self.photoFromDocument.title;
    } else {
        // Set the spinner while the photo is retrieved from Flickr
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        
        // Start async task to download the photo
        dispatch_queue_t downloadQueue = dispatch_queue_create("Flickr Photo Downloader", NULL);
        dispatch_async(downloadQueue, ^{
            NSString *fetchedPhotoId = self.photoFromDocument.identifier;
            NSURL *photoUrl = [NSURL URLWithString:self.photoFromDocument.photoURL];
            NSData *data = [[NSData alloc] initWithContentsOfURL:photoUrl];
            dispatch_async(dispatch_get_main_queue(), ^{
                // If the latest photo id is not the same as the fetched photo id
                // discard the fetched photo
                if (self.photoFromDocument.identifier == fetchedPhotoId) {
                    self.navigationItem.rightBarButtonItem = self.visitButton;
                    self.visitButton.title = UNVISIT;
                    // When photos are retrieved set the frame and scroll view zoom parameters
                    [self setPhotoDataView:data];
                    self.navigationItem.title = self.photoFromDocument.title;
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                }
                // Add any fetched photo into cache
                [[FlickrPhotoCache instance] addFlickrPhotoToCache:fetchedPhotoId withData:data];
            });
        });
        dispatch_release(downloadQueue);
    }
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
        self.onVacation = NO;
        [self updatePhotoView];
    }
}

- (void)setPhotoFromDocument:(Photo *)photoFromDocument
{
    if (_photoFromDocument != photoFromDocument) {
        _photoFromDocument = photoFromDocument;
        self.onVacation = YES;
        [self updatePhotoFromDocumentView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.photo != nil) {
        self.onVacation = NO;
        [self updatePhotoView];
    } else if (self.photoFromDocument != nil) {
        self.onVacation = YES;
        [self updatePhotoFromDocumentView];
    }
}

- (void)visit:(NSString *)vacationName
{
    [VacationHelper openVacation:vacationName usingBlock:^(UIManagedDocument *vacation) {
        // Add this photo to the vacation document
        [Photo photoWithFlickrInfo:self.photo inManagedObjectContext:vacation.managedObjectContext];
        [vacation saveToURL:vacation.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        self.visitButton.title = UNVISIT;
    }];
}

- (void)unvisit
{
    NSString *photoId;
    if (self.onVacation) {
        photoId = self.photoFromDocument.identifier;
    } else {
        photoId = [self.photo valueForKey:FLICKR_PHOTO_ID];
    }
    
    NSArray *vacations = [VacationHelper listVacations];
    for (NSString *vacationName in vacations) {
        [VacationHelper openVacation:vacationName usingBlock:^(UIManagedDocument *vacation) {
            Photo *photo = [Photo photoInDocumentWithFlickrId:photoId inManagedObjectContext:vacation.managedObjectContext];
            if (photo) {
                // Delete the photo from the vacation document
                [vacation.managedObjectContext deleteObject:photo];
                self.visitButton.title = VISIT;
                if (self.onVacation) {
                    self.photoFromDocument = nil;
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        }];
    }
}

- (void)vacationTableViewController:(VacationTableViewController *)sender didSelectVacationName:(NSString *)vacationName
{
    [self visit:vacationName];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)visitPressed:(UIBarButtonItem *)sender 
{
    VacationTableViewController *vacationTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VacationTableViewController"];
    [vacationTableViewController setDelegate:self];
    if ([sender.title isEqualToString:VISIT]) {
        [self presentModalViewController:vacationTableViewController animated:YES];
    } else {
        [self unvisit];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setImageView:nil];
    [self setVisitButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
