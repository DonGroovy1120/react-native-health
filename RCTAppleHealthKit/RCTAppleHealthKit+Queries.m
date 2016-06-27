//
//  RCTAppleHealthKit+Queries.m
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  Copyright © 2016 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

@implementation RCTAppleHealthKit (Queries)


- (void)fetchMostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *, NSError *))completion { NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];

    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:quantityType
                                                  predicate:predicate
                                                  limit:1
                                                  sortDescriptors:@[timeSortDescriptor]
                                                  resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                      if (!results) {
                                                          if (completion) {
                                                              completion(nil, error);
                                                          }
                                                          return;
                                                      }

                                                      if (completion) {
                                                          // If quantity isn't in the database, return nil in the completion block.
                                                          HKQuantitySample *quantitySample = results.firstObject;
                                                          HKQuantity *quantity = quantitySample.quantity;
                                                          completion(quantity, error);
                                                      }
                                                  }];

    [self.healthStore executeQuery:query];
}



- (void)fetchSumOfSamplesTodayForType:(HKQuantityType *)quantityType unit:(HKUnit *)unit completion:(void (^)(double, NSError *))completionHandler {
    NSPredicate *predicate = [RCTAppleHealthKit predicateForSamplesToday];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:quantityType
                                                          quantitySamplePredicate:predicate
                                                          options:HKStatisticsOptionCumulativeSum
                                                          completionHandler:^(HKStatisticsQuery *query, HKStatistics *result, NSError *error) {
        HKQuantity *sum = [result sumQuantity];
        
        if (completionHandler) {
            double value = [sum doubleValueForUnit:unit];
            completionHandler(value, error);
        }
    }];
    
    [self.healthStore executeQuery:query];
}

@end
