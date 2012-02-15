//
//  VacationTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "VacationTableViewController.h"
#import "StaticTableViewController.h"
#import "VacationHelper.h"

@implementation VacationTableViewController

@synthesize vacations = _vacations;
@synthesize delegate = _delegate;

- (void)setVacations:(NSArray *)vacations
{
    if (_vacations != vacations) {
        _vacations = vacations;
        [self.tableView reloadData];
    }   
}

- (void)loadVacations
{
    // Get a list of vacations to fill the table
    self.vacations = [VacationHelper listVacations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadVacations];
    // Set up the default vacations directory
    [VacationHelper openVacation:@"My Vacation" usingBlock:^(UIManagedDocument *vacation) {
        
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.vacations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Vacation";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell
    cell.textLabel.text = [self.vacations objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *vacationName = [self.vacations objectAtIndex:indexPath.row];
    [self.delegate vacationTableViewController:self didSelectVacationName:vacationName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSString *vacationName = [self.vacations objectAtIndex:indexPath.row];
    [segue.destinationViewController setVacationName:vacationName];
}

- (IBAction)addVacation:(UIBarButtonItem *)sender 
{
    // Create an alert to take in a vacation name as input
    UIAlertView *vacationAlert = [[UIAlertView alloc] initWithTitle:@"Add Vacation" message:@"Enter new vacation name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    
    [vacationAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *vacationNameField = [vacationAlert textFieldAtIndex:0];
    if (vacationNameField) {
        vacationNameField.autocorrectionType = UITextAutocorrectionTypeNo;
        vacationNameField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    
    [vacationAlert show];
}

- (IBAction)cancelPressed:(UIBarButtonItem *)sender
{
    // If no action is performed, simply dismiss
    [[self presentingViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Add a new vacation document
        NSString *vacationName = [[alertView textFieldAtIndex:0] text];
        [VacationHelper openVacation:vacationName usingBlock:^(UIManagedDocument *vacation) {
            [self loadVacations];
        }];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
