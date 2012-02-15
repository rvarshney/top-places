//
//  StaticTableViewController.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/17/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "StaticTableViewController.h"


@implementation StaticTableViewController
@synthesize vacationName = _vacationName;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setVacationName:(NSString *)vacationName
{
    if (_vacationName != vacationName) {
        _vacationName = vacationName;
        self.title = vacationName;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setVacationName:self.vacationName];
}

@end
