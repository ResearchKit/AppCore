//
//  APCCriteria.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import Foundation;

extern NSString const *APCCriteriaDateFormate;

typedef NS_ENUM(NSUInteger, APCCriteriaAnswerType) {
    APCCriteriaAnswerTypeChoice = 0,
    APCCriteriaAnswerTypeDate,
};

@interface APCCriteria : NSObject

@property (nonatomic, readwrite) APCCriteriaAnswerType answerType;

@property (nonatomic, strong) NSString *question;

@property (nonatomic, strong) NSArray *answers;

@property (nonatomic, readwrite) NSUInteger answerIndex;

@end
