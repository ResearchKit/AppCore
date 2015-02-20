//
//  APCMedicationModel.h
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@import  UIKit;

@interface APCMedicationModel : NSObject

@property  (nonatomic, strong)  NSString      *medicationName;
@property  (nonatomic, strong)  NSString      *medicationLabelColor;

@property  (nonatomic, strong)  NSDictionary  *frequencyAndDays;

@property  (nonatomic, strong)  NSNumber      *medicationDosageValue;
@property  (nonatomic, strong)  NSString      *medicationDosageText;

@end
