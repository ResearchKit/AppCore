//
//  HealthKitSelector.m
//  HealthKitSelector
//
//  Created by Dzianis Asanovich on 10/21/14.
//  Copyright (c) 2014 Dzianis Asanovich. All rights reserved.
//

#import "HealthKitManager.h"

@implementation HealthKitManager
{
    NSDictionary * fullMeasures;
}

+ (HealthKitManager*)sharedInstance
{
    static HealthKitManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        fullMeasures = [NSDictionary dictionaryWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"measures" ofType:@"plist"]];
    }
    return self;
}

-(void)connectToHealthKit: (CompletionBlock) completionBlock;
{
    if ([HKHealthStore isHealthDataAvailable]) {
        _healthStore = [[HKHealthStore alloc] init];
        
        NSSet *readDataTypes = [self dataTypesToRead];
        NSSet *writeDataTypes = [self dataTypesToWrite];
        
        [_healthStore requestAuthorizationToShareTypes: writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            // Handle success in your app here.
            completionBlock();
        }];
    }
}

-(NSDictionary *) getMeasures
{
    return fullMeasures;
}

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    NSSet * dataTypesToRead = [self dataTypesToRead];
    NSMutableSet * writeDataTypes = [dataTypesToRead mutableCopy];
    for (HKSampleType * type in dataTypesToRead)
    {
        if ([type.identifier isEqualToString: HKQuantityTypeIdentifierNikeFuel] || [type.identifier hasPrefix: @"HKCharacteristic"])
            
            [writeDataTypes removeObject: type];
    }
    
    return writeDataTypes;
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    NSMutableSet * fullSet = [NSMutableSet set];
    NSArray * allPermissions = [[HealthKitManager sharedInstance] getWholeIdentifiersCombined];
    for (NSString * identifier in allPermissions)
    {
        HKObjectType * sampleType = [HealthKitManager getObjectTypeForIdentifier: identifier];
        if (sampleType && ![sampleType.identifier hasPrefix: @"HKCorrelation"])
            [fullSet addObject: sampleType];
    }
    
    return fullSet;
}

-(NSArray *) getWholeIdentifiersCombined
{
    NSMutableArray * fullArray = [NSMutableArray array];
    for (NSString * key in fullMeasures)
    {
        [fullArray addObjectsFromArray: fullMeasures[key]];
    }
    return fullArray;
}

-(NSArray *) getQuantityIdentifiers
{
    NSArray * whole =[self getWholeIdentifiersCombined];
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] 'HKQuantityTypeIdentifier'"];
    NSArray *quantityArray = [whole filteredArrayUsingPredicate: bPredicate];
    return quantityArray;
}

-(void) getSamplesForIdentifier: (NSString*)identifier withCompletion: (CompletionSamplesBlock) completionBlock
{
    HKObjectType *objectType = [HealthKitManager getObjectTypeForIdentifier: identifier];
    if ([objectType isKindOfClass: [HKSampleType class]])
    {
        HKSampleType * sampleType = (HKSampleType*)objectType;
        NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate: nil endDate:nil options:HKQueryOptionNone];
        
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType: sampleType predicate:predicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
            if (error) {
                NSLog(@"An error occured fetching data. In your app, try to handle this gracefully. The error was: %@.", error);
                abort();
            }
            completionBlock(results);
        }];
        
        [[HealthKitManager sharedInstance].healthStore executeQuery:query];
    }
}

+(HKObjectType*) getObjectTypeForIdentifier: (NSString*) identifier
{
    HKObjectType * sampleType = nil;
    if ([identifier hasPrefix: @"HKQuantity"])
    {
        sampleType = [HKSampleType quantityTypeForIdentifier: identifier];
    }
    else if ([identifier hasPrefix: @"HKCorrelation"])
    {
        sampleType = [HKSampleType correlationTypeForIdentifier: identifier];
    }
    else if ([identifier hasPrefix: @"HKWorkoutTypeIdentifier"])
    {
        sampleType = [HKSampleType workoutType];
    }
    else if ([identifier hasPrefix: @"HKCategoryTypeIdentifier"])
    {
        sampleType = [HKSampleType categoryTypeForIdentifier: identifier];
    }
    else if ([identifier hasPrefix: @"HKCharacteristicTypeIdentifier"])
    {
        sampleType = [HKCharacteristicType characteristicTypeForIdentifier: identifier];
    }
    return sampleType;
}

+(NSArray *)getUnitsForIdentifier:(NSString *)identifier
{
    NSArray * allUnits = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"units" ofType:@"plist"]];
    NSMutableArray * compatibleUnits = [NSMutableArray array];
    HKSampleType * sampleType = (HKSampleType*)[HealthKitManager getObjectTypeForIdentifier: identifier];
    if ([sampleType isKindOfClass: [HKQuantityType class]])
    {
        for (NSString * unit in allUnits)
        {
            if ([(HKQuantityType*)sampleType isCompatibleWithUnit: [HKUnit unitFromString: unit]])
            {
                [compatibleUnits addObject: unit];
            }
        }
    }
    return compatibleUnits;
}

+(NSString *) getIdentifierReadable: (NSString*) identifier
{
    NSString * readable = identifier;
    if ([identifier hasPrefix: @"HKQuantityTypeIdentifier"])
    {
        readable = [identifier stringByReplacingOccurrencesOfString: @"HKQuantityTypeIdentifier" withString:@""];
    }
    else if ([identifier hasPrefix: @"HKCorrelationTypeIdentifier"])
    {
        readable = [identifier stringByReplacingOccurrencesOfString: @"HKCorrelationTypeIdentifier" withString:@""];
    }
    else if ([identifier hasPrefix: @"HKCategoryTypeIdentifier"])
    {
        readable = [identifier stringByReplacingOccurrencesOfString: @"HKCategoryTypeIdentifier" withString:@""];
    }
    else if ([identifier hasPrefix: @"HKCharacteristicTypeIdentifier"])
    {
        readable = [identifier stringByReplacingOccurrencesOfString: @"HKCharacteristicTypeIdentifier" withString:@""];
    }
    else if ([identifier hasPrefix: @"HKWorkoutActivityType"])
    {
        readable = [identifier stringByReplacingOccurrencesOfString: @"HKWorkoutActivityType" withString:@""];
    }
    return readable;
}

+(NSArray *)getWorkouts
{
    NSArray * allWorkouts = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"workouts" ofType:@"plist"]];
    return allWorkouts;
}

@end
