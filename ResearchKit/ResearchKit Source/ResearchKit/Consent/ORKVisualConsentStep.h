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


#import <ResearchKit/ORKStep.h>

ORK_ASSUME_NONNULL_BEGIN

@class ORKConsentDocument;

/**
 The `ORKVisualConsentStep` class is a step representing the visual consent sequence.
 To present visual consent, an `ORKConsentDocument`, with at least one section that
 is not of type `ORKConsentSectionTypeOnlyInDocument`, must be added to a visual
 consent step.
 
 To use a visual consent step, first create a consent document with at least one
 section. Then, attach it to a visual consent step. Put the visual consent step
 into a ResearchKit task, and present it with a task view controller.
 
 In ResearchKit, an `ORKVisualConsentStep` is used to present a series of simple
 graphics to help study participants understand the content of an informed
 consent document. The default provided graphics come with animated transitions.
 The actual textual content should relate to the specific study being consented.
 To provide this content, the developer should populate the `consentDocument`.
 
 `ORKVisualConsentStep` produces an `ORKStepResult`, the dates for which indicate how
 long the participant has spent in the consent process as a whole, and the route by which
 they exit the consent process.
 */

ORK_CLASS_AVAILABLE
@interface ORKVisualConsentStep : ORKStep

/**
 Convenience initializer.
 
 @param identifier          Identifying string for this visual consent step, unique within the document.
 @param consentDocument     Informed consent document.
 */
- (instancetype)initWithIdentifier:(NSString *)identifier document:(ORK_NULLABLE ORKConsentDocument *)consentDocument;

/**
 The consent document whose sections determine the order and appearance of scenes
 in `ORKVisualConsentStep`.
 */
@property (nonatomic, strong, ORK_NULLABLE) ORKConsentDocument *consentDocument;

@end

ORK_ASSUME_NONNULL_END
