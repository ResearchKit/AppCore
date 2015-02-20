//
//  APCMedicationFollower.h
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APCMedicationFollower : NSObject

@property  (nonatomic, strong)  NSString      *medicationName;
@property  (nonatomic, strong)  NSNumber      *numberOfDosesPrescribed;
@property  (nonatomic, strong)  NSNumber      *numberOfDosesTaken;

@end
