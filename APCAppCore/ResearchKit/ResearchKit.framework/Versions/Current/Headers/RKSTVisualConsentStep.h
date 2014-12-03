//
//  RKSTVisualConsentStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@class RKSTConsentDocument;

@interface RKSTVisualConsentStep : RKSTStep

- (instancetype)initWithDocument:(RKSTConsentDocument *)consentDocument;

@property (nonatomic, strong) RKSTConsentDocument *consentDocument;

@end
