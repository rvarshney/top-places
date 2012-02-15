//
//  TagTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "TagTableViewController.h"
#import "VacationHelper.h"
#import "VacationPhotoTableViewController.h"
#import "Tag.h"

@interface TagTableViewController()
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation TagTableViewController
@synthesize searchBar = _searchBar;

@synthesize vacationName = _vacationName;

- (void)setupFetchedResultsController:(UIManagedDocument *)vacation
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    // Sort by the highest photo counts
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"photoCount" ascending:NO selector:@selector(compare:)]];
    
    // Predicate results based on text in the search bar
    if (self.searchBar.text && ![self.searchBar.text isEqualToString:@""]) {
        request.predicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", self.searchBar.text];
    }

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
    static NSString *CellIdentifier = @"Tag";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Get the tag for the given row
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell
    cell.textLabel.text = tag.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photos", tag.photoCount];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Tag *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [segue.destinationViewController setSearchTag:tag];
    [segue.destinationViewController setVacationName:self.vacationName];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.searchBar.delegate = self;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.showsCancelButton = NO;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // Reset the fetchResultsController to include a predicate based on the search text
    [VacationHelper openVacation:self.vacationName usingBlock:^(UIManagedDocument *vacation) {
        [self setupFetchedResultsController:vacation];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text= @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

@end
