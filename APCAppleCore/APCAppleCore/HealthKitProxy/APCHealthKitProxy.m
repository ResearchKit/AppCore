//
//  HKManager.m
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APCHealthKitProxy.h"

@interface APCHealthKitProxy ()

@property (nonatomic, strong) NSMutableSet *shareTypes;

@property (nonatomic, strong) NSMutableSet *readTypes;

@end

@implementation APCHealthKitProxy

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        _store = [HKHealthStore new];
        [self loadShareTypes];
        [self loadReadTypes];
    }
    return self;
}

- (void) loadShareTypes {
    self.shareTypes = [NSMutableSet set];
    
    {
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        [self.shareTypes addObject:type];
    }
    
    {
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        [self.shareTypes addObject:type];
    }
}

- (void) loadReadTypes {
    self.readTypes = [NSMutableSet set];
    
    {
        HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
        [self.readTypes addObject:type];
    }
    
    {
        HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
        [self.readTypes addObject:type];
    }
    
    {
        HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
        [self.readTypes addObject:type];
    }
    
    {
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        [self.readTypes addObject:type];
    }
    
    {
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
        [self.readTypes addObject:type];
    }
}


#pragma mark - Public methods

- (void) authenticate:(void (^)(BOOL granted, NSError *error))completion {
    [self.store requestAuthorizationToShareTypes:self.shareTypes readTypes:self.readTypes completion:completion];
}

- (void) fillBiologicalInfo:(APCProfile *)profile {
    {
        NSError *error;
        profile.dateOfBirth = [self.store dateOfBirthWithError:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
    {
        NSError *error;
        HKBiologicalSexObject *sexObject = [self.store biologicalSexWithError:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        profile.gender = sexObject.biologicalSex;
    }
    
    {
        NSError *error;
        HKBloodTypeObject *bloodTypeObject = [self.store bloodTypeWithError:&error];
        
        if (error) {
            NSLog(@"%@", error);
        }
        
        profile.bloodType = bloodTypeObject.bloodType;
    }
}

- (void) latestHeight:(void (^)(HKQuantity *quantity, NSError *error))completion {
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    [self latestSampleForType:sampleType completion:completion];
}

- (void) latestWeight:(void (^)(HKQuantity *quantity, NSError *error))completion {
    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self latestSampleForType:sampleType completion:completion];
}


#pragma mark - Private Methods

- (void) latestSampleForType:(HKSampleType *)sampleType completion:(void (^)(HKQuantity *quantity, NSError *error))completion {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:nil limit:1 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (error) {
            completion(nil, error);
        }
        else {
            HKQuantitySample *sample = results.lastObject;
            
            completion(sample.quantity, nil);
        }
    }];
    
    [self.store executeQuery:query];
}

@end
