//
//  RKSTVisualConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKSTConsentDocument;

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTVisualConsentStep : RKSTStep

- (instancetype)initWithIdentifier:(NSString *)identifier document:(RKSTConsentDocument *)consentDocument;

@property (nonatomic, strong) RKSTConsentDocument *consentDocument;

@end
