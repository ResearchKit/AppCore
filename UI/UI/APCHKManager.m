//
//  HKManager.m
//  UI
//
//  Created by Karthik Keyan on 9/6/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCProfile.h"
#import "APCHKManager.h"

@implementation APCHKManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _store = [HKHealthStore new];
    }
    return self;
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

- (NSSet *) shareTypes {
    static NSMutableSet *types;
    
    if (!types) {
        types = [NSMutableSet set];
        
//        {
//            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
//            [types addObject:type];
//        }
//        
//        {
//            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
//            [types addObject:type];
//        }
//        
//        {
//            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//            [types addObject:type];
//        }
        
        {
            HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
            [types addObject:type];
        }
        
        {
            HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
            [types addObject:type];
        }
    }
    
    return types;
}

- (NSSet *) readTypes {
    static NSMutableSet *types;
    
    if (!types) {
        types = [NSMutableSet set];
        
        {
            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
            [types addObject:type];
        }
        
        {
            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];
            [types addObject:type];
        }
        
        {
            HKCharacteristicType *type = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
            [types addObject:type];
        }
        
        {
            HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
            [types addObject:type];
        }
        
        {
            HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
            [types addObject:type];
        }
    }
    
    return types;
}

@end
