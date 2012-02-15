//
//  VacationPhotoTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "VacationPhotoTableViewController.h"
#import "VacationHelper.h"
#import "PhotoViewController.h"

@implementation VacationPhotoTableViewController

@synthesize place = _place;
@synthesize searchTag = _searchTag;
@synthesize vacationName = _vacationName;

- (void)setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    
    // If this view controller is for a place, check the takenAt relationship
    if (self.place) {
        request.predicate = [NSPredicate predicateWithFormat:@"takenAt.name = %@", self.place.name];
    } else if (self.searchTag) {
        // Check if any of the tags have the same name
        request.predicate = [NSPredicate predicateWithFormat:@"ANY taggedAs.name = %@", self.searchTag.name];        
    }
   
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:vacation.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}

- (void)setSearchTag:(Tag *)searchTag
{
    if (_searchTag != searchTag) {
        _searchTag = searchTag;
        self.title = searchTag.name;
    }
}

- (void)setPlace:(Place *)place
{
    if (_place != place) {
        _place = place;
        self.title = place.name;
    }
}

- (void)setVacationName:(NSString *)vacationName
{
    if (_vacationName != vacationName) {
        _vacationName = vacationName;
        [VacationHelper openVacation:self.vacationName usingBlock:^(UIManagedDocument *vacation) {
            [self setupFetchedResultsController:vacation];
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [segue.destinationViewController setPhotoFromDocument:photo];
}
@end
