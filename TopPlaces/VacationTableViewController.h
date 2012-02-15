//
//  VacationTableViewController.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@class VacationTableViewController;

@protocol VacationTableViewControllerDelegate <NSObject>
- (void)vacationTableViewController:(VacationTableViewController *)sender didSelectVacationName:(NSString *)vacationName;
@end

@interface VacationTableViewController : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *vacations;
@property (nonatomic, weak) id <VacationTableViewControllerDelegate> delegate;

@end
