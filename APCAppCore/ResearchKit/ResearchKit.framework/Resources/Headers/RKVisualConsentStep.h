//
//  RKVisualConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKConsentDocument;

RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKVisualConsentStep : RKStep

- (instancetype)initWithIdentifier:(NSString *)identifier document:(RKConsentDocument *)consentDocument;

@property (nonatomic, strong) RKConsentDocument *consentDocument;

@end
