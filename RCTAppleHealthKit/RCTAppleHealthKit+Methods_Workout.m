//
//  RCTAppleHealthKit+Methods_Workout.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "RCTAppleHealthKit+Methods_Workout.h"
#import "RCTAppleHealthKit+Utils.h"
#import "RCTAppleHealthKit+Queries.h"

#import "RNAppleHealthKit-Swift.h"

@implementation RCTAppleHealthKit (Methods_Workout)


- (void)workout_getRoute:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{

    NSString *uid = [RCTAppleHealthKit stringFromOptions:input key:@"id" withDefault:@""];
    
    NSUUID *uuid;
    
    @try {
        uuid = [[NSUUID alloc] initWithUUIDString:uid];
    } @catch (NSException *exception) {
        callback(@[RCTMakeError(@"Error converting id to uuid", nil, nil)]);
        return;
    }
    
    if(!uuid){
        callback(@[RCTMakeError(@"An id is required", nil, nil)]);
        return;
    }

    NSPredicate *predicate = [HKQuery predicateForObjectWithUUID:uuid];

    HKSampleType *samplesType = [HKSampleType workoutType];

    void (^completion)(NSArray *results, NSError *error);

    completion = ^(NSArray *results, NSError *error) {
        if (results){
            
            //only one workout should return from the query
            for (HKWorkout *sample in results) {
                // do something with object
                HKSampleType *type = [HKSeriesType workoutRouteType];

                NSPredicate *pre = [HKQuery predicateForObjectsFromWorkout:sample];
                
                void (^routeCompletion)(NSDictionary *results, NSError *error);

                routeCompletion = ^(NSDictionary *results, NSError *error) {
                    if (results){
                        callback(@[[NSNull null], results]);
                        
                        return;
                    } else {
                        NSLog(@"error getting samples: %@", error);
                        callback(@[RCTMakeError(@"error getting samples. Activity possibly does not have a route.", error, nil)]);
                        return;
                    }
                };
                
                
                [self fetchWorkoutRoute:type
                                  predicate:pre
                                     anchor:nil
                                      limit:HKObjectQueryNoLimit
                                 completion:routeCompletion];
                
                break;
            }
            
        } else {
            NSLog(@"error getting samples: %@", error);
            callback(@[RCTMakeError(@"error getting samples:", error, nil)]);

            return;
        }
    };


    [self fetchWorkoutById:samplesType
                        unit:[HKUnit countUnit]
                   predicate:predicate
                   ascending:false
                       limit:HKObjectQueryNoLimit
                  completion:completion];
}


- (void)workout_getAnchoredQuery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    
    HKSampleType *workoutType = [HKObjectType workoutType];
    HKQueryAnchor *anchor = [self.rnAppleHealthKit hkAnchorFrom:input];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    
    NSPredicate *predicate = [self.rnAppleHealthKit predicateForAnchoredQueriesWithStartDate:startDate endDate:endDate];

    void (^completion)(NSDictionary *results, NSError *error);

    completion = ^(NSDictionary *results, NSError *error) {
        if (results){
            callback(@[[NSNull null], results]);

            return;
        } else {
            NSLog(@"error getting samples: %@", error);
            callback(@[RCTMakeError(@"error getting samples", error, nil)]);

            return;
        }
    };

    [self fetchAnchoredWorkouts:workoutType
                      predicate:predicate
                         anchor:anchor
                          limit:limit
                     completion:completion];
}

- (void)workout_save: (NSDictionary *)input callback: (RCTResponseSenderBlock)callback {
    HKWorkoutActivityType type = [self.rnAppleHealthKit hkWorkoutActivityTypeFrom:input key:@"type" defaultValue:HKWorkoutActivityTypeAmericanFootball];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:nil];
    HKQuantity *totalEnergyBurned = [self.rnAppleHealthKit hkQuantityFrom:input valueKey:@"energyBurned" unitKey:@"energyBurnedUnit"];
    HKQuantity *totalDistance = [self.rnAppleHealthKit hkQuantityFrom:input valueKey:@"distance" unitKey:@"distanceUnit"];


    HKWorkout *workout = [
                          HKWorkout workoutWithActivityType:type startDate:startDate endDate:endDate workoutEvents:nil totalEnergyBurned:totalEnergyBurned totalDistance:totalDistance metadata: nil
                          ];

    void (^completion)(BOOL success, NSError *error);

    completion = ^(BOOL success, NSError *error){
        if (!success) {
            NSLog(@"An error occured saving the workout %@. The error was: %@.", workout, error);
            callback(@[RCTMakeError(@"An error occured saving the workout", error, nil)]);

            return;
        }
        callback(@[[NSNull null], [[workout UUID] UUIDString]]);
    };

    [self.rnAppleHealthKit.healthStore saveObject:workout withCompletion:completion];
}
@end
