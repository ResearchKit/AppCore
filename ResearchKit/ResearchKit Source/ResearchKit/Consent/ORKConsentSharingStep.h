/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import <ResearchKit/ResearchKit.h>

ORK_ASSUME_NONNULL_BEGIN

/**
 The `ORKConsentSharingStep` class represents a custom question step with certain
 content pre-populated to represent a question about how far the user accepts
 data to be shared after collection.
 
 To use the consent sharing step, include it in a task and present that task
 with a task view controller.
 
 The title, text, and answer format are all pre-populated in this step, so it
can easily be incorporated into the review.
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSharingStep : ORKQuestionStep

/**
 Primary initializer.
 
 This initializer populates localized title, text and answer format using the
 provided parameters.
 
 @param identifier                      Identiifer of the step.
 @param investigatorShortDescription    Short description of the investigator, for instance, 'Stanford'
 @param investigatorLongDescription     Extended description of the investigator and partners, for instance,
                                        'Stanford and its partners'
 @param localizedLearnMoreHTMLContent   HTML content to be displayed when the user
                                        taps on "Learn More".
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
      investigatorShortDescription:(NSString *)investigatorShortDescription
       investigatorLongDescription:(NSString *)investigatorLongDescription
     localizedLearnMoreHTMLContent:(NSString *)localizedLearnMoreHTMLContent;

/// Localized content to be presented in the "Learn More" section for this step.
@property (nonatomic, copy) NSString *localizedLearnMoreHTMLContent;

@end

ORK_ASSUME_NONNULL_END
