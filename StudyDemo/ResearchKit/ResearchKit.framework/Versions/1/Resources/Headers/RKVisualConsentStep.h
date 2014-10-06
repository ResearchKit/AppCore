//
//  RKVisualConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKConsentDocument;

@interface RKVisualConsentStep : RKStep

- (instancetype)initWithDocument:(RKConsentDocument *)consentDocument;

@property (nonatomic, strong) RKConsentDocument *consentDocument;

@end
