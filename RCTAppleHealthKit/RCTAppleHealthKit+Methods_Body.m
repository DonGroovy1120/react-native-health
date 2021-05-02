//
//  RCTAppleHealthKit+Methods_Body.m
//  RCTAppleHealthKit
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "RCTAppleHealthKit+Methods_Body.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import "RNAppleHealthKit-Swift.h"

@implementation RCTAppleHealthKit (Methods_Body)


- (void)body_getLatestWeight:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];
    
    [self fetchMostRecentQuantitySampleOfType:weightType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            callback(@[RCTJSErrorFromNSError(error)]);
        }
        else {
            // Determine the weight in the required unit.
            double usersWeight = [mostRecentQuantity doubleValueForUnit:unit];
            NSDictionary *response = @{
                    @"value" : @(usersWeight),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}


- (void)body_getWeightSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:weightType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
            callback(@[[NSNull null], results]);
            return;
        } else {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
    }];
}


- (void)body_saveWeight:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double weight = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:[NSDate date]];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];

    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:unit doubleValue:weight];
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate];

    [self.rnAppleHealthKit.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(weight)]);
    }];
}


- (void)body_getLatestBodyMassIndex:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bmiType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];

    [self fetchMostRecentQuantitySampleOfType:bmiType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            callback(@[RCTJSErrorFromNSError(error)]);
        }
        else {
            // Determine the bmi in the required unit.
            HKUnit *countUnit = [HKUnit countUnit];
            double bmi = [mostRecentQuantity doubleValueForUnit:countUnit];

            NSDictionary *response = @{
                    @"value" : @(bmi),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}


- (void)body_saveBodyMassIndex:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double bmi = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"date" defaultDate:[NSDate date]];
    HKUnit *unit = [HKUnit countUnit];

    HKQuantity *bmiQuantity = [HKQuantity quantityWithUnit:unit doubleValue:bmi];
    HKQuantityType *bmiType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    HKQuantitySample *bmiSample = [HKQuantitySample quantitySampleWithType:bmiType quantity:bmiQuantity startDate:sampleDate endDate:sampleDate];

    [self.rnAppleHealthKit.healthStore saveObject:bmiSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(bmi)]);
    }];
}


- (void)body_getLatestHeight:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit inchUnit]];;

    [self fetchMostRecentQuantitySampleOfType:heightType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"error getting latest height: %@", error);
            callback(@[RCTMakeError(@"error getting latest height", error, nil)]);
        }
        else {
            // Determine the height in the required unit.
            double height = [mostRecentQuantity doubleValueForUnit:unit];

            NSDictionary *response = @{
                    @"value" : @(height),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}


- (void)body_getHeightSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];

    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit inchUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];

    [self fetchQuantitySamplesOfType:heightType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
        if(results){
          callback(@[[NSNull null], results]);
          return;
        } else {
          callback(@[RCTJSErrorFromNSError(error)]);
          return;
        }
    }];
}


- (void)body_saveHeight:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double height = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"date" defaultDate:[NSDate date]];
    HKUnit *heightUnit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit inchUnit]];

    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:heightUnit doubleValue:height];
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:sampleDate endDate:sampleDate];

    [self.rnAppleHealthKit.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            callback(@[RCTJSErrorFromNSError(error)]);
            return;
        }
        callback(@[[NSNull null], @(height)]);
    }];
}


- (void)body_getLatestBodyFatPercentage:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bodyFatPercentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];

    [self fetchMostRecentQuantitySampleOfType:bodyFatPercentType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            callback(@[RCTJSErrorFromNSError(error)]);
        }
        else {
            // Determine the weight in the required unit.
            HKUnit *percentUnit = [HKUnit percentUnit];
            double percentage = [mostRecentQuantity doubleValueForUnit:percentUnit];

            percentage = percentage * 100;

            NSDictionary *response = @{
                    @"value" : @(percentage),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}


- (void)body_getBodyFatPercentageSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *bodyFatPercentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];
    
    HKUnit *unit = [HKUnit percentUnit];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];
    
    [self fetchQuantitySamplesOfType:bodyFatPercentType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
                              if(results){
                                  callback(@[[NSNull null], results]);
                                  return;
                              } else {
                                  NSLog(@"error getting body fat percentage samples: %@", error);
                                  callback(@[RCTMakeError(@"error getting body fat percentage samples:", error, nil)]);
                                  return;
                              }
                          }];
}


- (void)body_saveBodyFatPercentage:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double percentage = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"date" defaultDate:[NSDate date]];
    HKUnit *unit = [HKUnit percentUnit];
    
    percentage = percentage / 100;

    HKQuantity *bodyFatPercentQuantity = [HKQuantity quantityWithUnit:unit doubleValue:percentage];
    HKQuantityType *bodyFatPercentType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];
    HKQuantitySample *bodyFatPercentSample = [HKQuantitySample quantitySampleWithType:bodyFatPercentType quantity:bodyFatPercentQuantity startDate:sampleDate endDate:sampleDate];
    
    [self.rnAppleHealthKit.healthStore saveObject:bodyFatPercentSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error saving body fat percent sample: %@", error);
            callback(@[RCTMakeError(@"error saving body fat percent sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(percentage)]);
    }];
}


- (void)body_saveBodyTemperature:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double temperature = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:[NSDate date]];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit degreeFahrenheitUnit]];

    HKQuantity *temperatureQuantity = [HKQuantity quantityWithUnit:unit doubleValue:temperature];
    HKQuantityType *bodyTemperatureType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    HKQuantitySample *bodyTemperatureSample = [HKQuantitySample quantitySampleWithType:bodyTemperatureType quantity:temperatureQuantity startDate:sampleDate endDate:sampleDate];

    [self.rnAppleHealthKit.healthStore saveObject:bodyTemperatureSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error saving body temperature sample: %@", error);
            callback(@[RCTMakeError(@"error saving body temperature sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(temperature)]);
    }];
}


- (void)body_getLatestLeanBodyMass:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *leanBodyMassType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass];

    [self fetchMostRecentQuantitySampleOfType:leanBodyMassType
                                    predicate:nil
                                   completion:^(HKQuantity *mostRecentQuantity, NSDate *startDate, NSDate *endDate, NSError *error) {
        if (!mostRecentQuantity) {
            callback(@[RCTJSErrorFromNSError(error)]);
        }
        else {
            HKUnit *weightUnit = [HKUnit poundUnit];
            double leanBodyMass = [mostRecentQuantity doubleValueForUnit:weightUnit];

            NSDictionary *response = @{
                    @"value" : @(leanBodyMass),
                    @"startDate" : [self.rnAppleHealthKit buildISO8601StringFrom:startDate],
                    @"endDate" : [self.rnAppleHealthKit buildISO8601StringFrom:endDate],
            };

            callback(@[[NSNull null], response]);
        }
    }];
}


- (void)body_getLeanBodyMassSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKQuantityType *leanBodyMassType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass];
    
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];
    NSUInteger limit = [RCTAppleHealthKit uintFromOptions:input key:@"limit" withDefault:HKObjectQueryNoLimit];
    BOOL ascending = [RCTAppleHealthKit boolFromOptions:input key:@"ascending" withDefault:false];
    NSDate *startDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:nil];
    NSDate *endDate = [self.rnAppleHealthKit dateFrom:input key:@"endDate" defaultDate:[NSDate date]];
    if(startDate == nil){
        callback(@[RCTMakeError(@"startDate is required in options", nil, nil)]);
        return;
    }
    NSPredicate * predicate = [self.rnAppleHealthKit predicateForSamplesBetweenWithStartDate:startDate endDate:endDate];
    
    [self fetchQuantitySamplesOfType:leanBodyMassType
                                unit:unit
                           predicate:predicate
                           ascending:ascending
                               limit:limit
                          completion:^(NSArray *results, NSError *error) {
                              if(results){
                                  callback(@[[NSNull null], results]);
                                  return;
                              } else {
                                  NSLog(@"error getting lean body mass samples: %@", error);
                                  callback(@[RCTMakeError(@"error getting lean body mass samples:", error, nil)]);
                                  return;
                              }
                          }];
}


- (void)body_saveLeanBodyMass:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    double mass = [[input objectForKey:@"value"] doubleValue];
    NSDate *sampleDate = [self.rnAppleHealthKit dateFrom:input key:@"startDate" defaultDate:[NSDate date]];
    HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];
    
    HKQuantity *massQuantity = [HKQuantity quantityWithUnit:unit doubleValue:mass];
    HKQuantityType *massType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass];
    HKQuantitySample *massSample = [HKQuantitySample quantitySampleWithType:massType quantity:massQuantity startDate:sampleDate endDate:sampleDate];
    
    [self.rnAppleHealthKit.healthStore saveObject:massSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error saving lean body mass sample: %@", error);
            callback(@[RCTMakeError(@"error saving lean body mass sample", error, nil)]);
            return;
        }
        callback(@[[NSNull null], @(mass)]);
    }];
}

@end
