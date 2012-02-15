//
//  VacationHelper.m
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "VacationHelper.h"

@implementation VacationHelper

static NSMutableDictionary *vacations;

+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock
{
    if (vacationName && ![vacationName isEqualToString:@""]) {
        UIManagedDocument *vacationDocument = [vacations objectForKey:vacationName];
        NSLog(@"Opening vacation document: %@", vacationDocument);
    
        if (vacationDocument == nil) {
            NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            url = [url URLByAppendingPathComponent:vacationName];
            vacationDocument = [[UIManagedDocument alloc] initWithFileURL:url];
            if (vacations == nil) {
                vacations = [[NSMutableDictionary alloc] init];
            }
            [vacations setObject:vacationDocument forKey:vacationName];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[vacationDocument.fileURL path]]) {
            // Document does not exist on disk, so create it
            [vacationDocument saveToURL:vacationDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateClosed) {
            // Document exists on disk, but we need to open it
            [vacationDocument openWithCompletionHandler:^(BOOL success) {
                completionBlock(vacationDocument);
            }];
        } else if (vacationDocument.documentState == UIDocumentStateNormal) {
            // Document is already open and ready to use
            completionBlock(vacationDocument);
        } else {
            NSLog(@"Unknown document state");
        }
    } else {
        completionBlock(nil);
    }
}

+ (NSArray *)listVacations
{
    // Read the contents of the document directory for a list of vacations
    NSError *error;
    NSMutableArray *vacations = [[NSMutableArray alloc] init];
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options: NSDirectoryEnumerationSkipsHiddenFiles error:&error];

    if (error == nil) {
        for (NSURL *vacationURL in array) {
            [vacations addObject:[vacationURL lastPathComponent]];
        }
    } else {
        NSLog(@"Error retrieving document files");
    }
    
    if ([vacations count] == 0) {
        NSString *defaultVacationName = @"My Vacation";
        [vacations addObject:defaultVacationName];
    }
    return vacations;
}

@end
