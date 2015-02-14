//
//  ORKVisualConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ORKStep.h>

@class ORKConsentDocument;

ORK_CLASS_AVAILABLE
@interface ORKVisualConsentStep : ORKStep

- (instancetype)initWithIdentifier:(NSString *)identifier document:(ORKConsentDocument *)consentDocument;

@property (nonatomic, strong) ORKConsentDocument *consentDocument;

@end
