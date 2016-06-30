//
//  RCTAppleHealthKit+Methods_Fitness.h
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  Copyright © 2016 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Methods_Fitness)

- (void)fitness_getStepCountForToday:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)fitness_getStepCountForDay:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;

- (void)fitness_getDailyStepCounts:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;

- (void)fitness_getDailyStepSamples:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;

@end
