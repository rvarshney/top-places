//
//  VacationHelper.h
//  TopPlaces
//
//  Created by Ruchi Varshney on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^completion_block_t)(UIManagedDocument *vacation);

@interface VacationHelper : NSObject
+ (void)openVacation:(NSString *)vacationName usingBlock:(completion_block_t)completionBlock;
+ (NSArray *)listVacations;
@end