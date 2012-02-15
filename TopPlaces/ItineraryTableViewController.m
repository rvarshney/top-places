//
//  ItineraryTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "ItineraryTableViewController.h"
#import "VacationHelper.h"
#import "VacationPhotoTableViewController.h"
#import "Place.h"

@implementation ItineraryTableViewController

@synthesize vacationName = _vacationName;

- (void)setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Place"];
    // Sort results by the date the place was added to the document
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"visitedOn" ascending:YES selector:@selector(compare:)]];
    
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:vacation.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
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
    static NSString *CellIdentifier = @"Itinerary";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Get the place for the given row
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell
    cell.textLabel.text = place.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photos", [place.photos count]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [segue.destinationViewController setPlace:place];
    [segue.destinationViewController setVacationName:self.vacationName];
}

@end
