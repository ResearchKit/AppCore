//
//  HealthKitSelector.h
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

typedef void(^CompletionBlock)();
typedef void(^CompletionSamplesBlock)(NSArray * array);

@interface HealthKitManager : NSObject

@property (nonatomic, strong) HKHealthStore * healthStore;

+(HealthKitManager*) sharedInstance;

-(void)connectToHealthKit: (CompletionBlock) completionBlock;

-(NSDictionary *) getMeasures;

-(NSArray *) getWholeIdentifiersCombined;

-(NSArray *) getQuantityIdentifiers;

-(void) getSamplesForIdentifier: (NSString*)identifier withCompletion: (CompletionSamplesBlock) completionBlock;

+(HKObjectType*) getObjectTypeForIdentifier: (NSString*) identifier;

+(NSArray *)getUnitsForIdentifier:(NSString *)identifier;

+(NSString *) getIdentifierReadable: (NSString*) identifier;

+(NSArray *)getWorkouts;

@end
