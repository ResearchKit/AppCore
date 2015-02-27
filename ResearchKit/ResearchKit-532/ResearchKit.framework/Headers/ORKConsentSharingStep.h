//
//  ORKConsentSharingStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>



ORK_CLASS_AVAILABLE
@interface ORKConsentSharingStep : ORKQuestionStep

- (instancetype)initWithIdentifier:(NSString *)identifier
      investigatorShortDescription:(NSString *)investigatorShortDescription
       investigatorLongDescription:(NSString *)investigatorLongDescription
     localizedLearnMoreHTMLContent:(NSString *)localizedLearnMoreHTMLContent;

@property (nonatomic, copy) NSString *localizedLearnMoreHTMLContent;

@end
