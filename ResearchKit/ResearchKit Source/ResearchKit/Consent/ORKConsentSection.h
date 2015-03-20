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


#import <UIKit/UIKit.h>
#import <ResearchKit/ResearchKit.h>


ORK_ASSUME_NONNULL_BEGIN

/**
 `ORKConsentSectionType` enumerates the pre-defined visual consent sections
 available in ResearchKit.
 
 Although the visuals are pre-defined, and default localized titles and learn
 more button titles are provided, the "summary" strapline on each visual consent
 page, and the actual Learn More content, will be specific to each individual
 study and must be provided in `ORKConsentSection`.
 
 Not all of these sections may be applicable to every study, and most studies
 are likely to require additional sections.
 */
typedef NS_ENUM(NSInteger, ORKConsentSectionType) {
    /**
     Overview of the informed consent process.
     
     This content could inform the user of what to expect during the process,
     and provide general background information on the purpose of the study.
     */
    ORKConsentSectionTypeOverview,
    
    
    /**
     Section informing the user that sensor data will be collected.
     
     This content could detail what sensors will be used, for how long,
     and for what purpose.
     */
    ORKConsentSectionTypeDataGathering,
    
    /**
     Section describing the privacy policies for the study.
     
     Could describe how data will be protected, any processes in place
     to de-identify or sanitize the data collected, and address the risks
     involved.
     */
    ORKConsentSectionTypePrivacy,
    
    /**
     Section describing how the data collected will be used.
     
     This might include details of who will have access to it, what types of
     analyses will be performed, and what degree of control the participant
     may have over the data once it is collected.
     */
    ORKConsentSectionTypeDataUse,
    
    /**
     Section describing how much time will be required for the study.
     
     This could give the user an idea what to expect as they participate.
     */
    ORKConsentSectionTypeTimeCommitment,
    
    /**
     Section describing survey use in the study.
     
     This could indicate how survey data will be collected, for what purpose,
     and make it clear to what extent participation is optional.
     */
    ORKConsentSectionTypeStudySurvey,
    
    /**
     Section describing active task use in the study.
     
     This could describe what kinds of tasks will need to be performed, how
     often, and for what purpose. If there are any risks involved, they could
     also be communicated.
     */
    ORKConsentSectionTypeStudyTasks,
    
    
    /**
     Section describing how to withdraw from the study.
     
     The user may wish to be able to withdraw. This could describe policies
     around the user's data when they withdraw.
     */
    ORKConsentSectionTypeWithdrawing,
    
    /**
     Type representing a custom section.
     
     Custom sections do not have pre-defined title, summary, content, image,
     or animation. A consent document may have as many or as few custom sections
     as needed.
     */
    ORKConsentSectionTypeCustom,
    
    /**
     Document-only sections.
     
     These are ignored for `ORKVisualConsentStep` and are only
     displayed in `ORKConsentReviewStep` (assuming there is no `htmlReviewContent`
     override).
     */
    ORKConsentSectionTypeOnlyInDocument
} ORK_ENUM_AVAILABLE;

/**
 The `ORKConsentSection` class represents one section in an `ORKConsentDocument`. Each
 `ORKConsentSection` (apart from those of type `ORKConsentSectionTypeOnlyInDocument`)
 corresponds to a page in an `ORKVisualConsentStep`, or a section in the document
 reviewed in `ORKConsentReviewStep`.
 
 Initializing with one of the defined section types can pre-populate the title,
 and provide a default image and animation (where appropriate). These properties
 can all be overridden, or the type `ORKConsentSectionTypeCustom` can be used to
 avoid any pre-population.
 
 Developer provided content of the `ORKConsentSection` must be appropriate to the
 document language.
 
 */
ORK_CLASS_AVAILABLE
@interface ORKConsentSection : NSObject <NSSecureCoding, NSCopying>

/**
 Initializer.
 
 Populates predefined title and summary for all types except for
 `ORKConsentSectionTypeCustom` and `ORKConsentSectionTypeOnlyInDocument`.
 
 @param type     Consent section type
 */
- (instancetype)initWithType:(ORKConsentSectionType)type;

/**
 The type of section (read-only).
 
 Indicates whether a pre-defined image, title, and animation are present.
 */
@property (nonatomic, readonly) ORKConsentSectionType type;

/**
 Title of the consent section.
 
 Displayed as scene title in the animated consent sequence.
 Prefilled unless type is `ORKConsentSectionTypeCustom` or `ORKConsentSectionTypeOnlyInDocument`.
 Also included in the PDF file, but can be overridden with `formalTitle`.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *title;

/**
 The formal title of the section, for use in the legal document.
 
 If `nil`, the `title` is used in the legal document instead.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *formalTitle;

/**
 A short summary of the content.
 
 The summary is displayed as description text in the animated consent sequence.
 The summary should be limited in length, so that the consent can be reliably
 displayed on smaller screens.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *summary;

/**
 The content of the section.
 
 In `ORKConsentReviewStep` or in PDF file generation, printed as the section's
 content.  Displayed as Learn More content in an `ORKVisualConsentStep`.
 
 This property is never pre-populated based on the `type`.
 
 If both content and `htmlContent` are non-nil, `htmlContent` field will be used.
 
 This string should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *content;

/**
 HTML content to override the `content` property if additional formatting is needed.
 
 Sometimes plain text content is not sufficient to convey important details
 during the consent process. HTML content provided on this property takes
 precedence over the `content` property.
 
 In `ORKConsentReviewStep` or in PDF file generation, printed as the section's
 content.  Displayed as Learn More content in an `ORKVisualConsentStep`.
 
 If both `content` and `htmlContent` are non-`nil,` `htmlContent` will be used.
 
 This content should be localized to the document language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *htmlContent;

/**
 A custom illustration for the consent.
 
 The custom image can override the image associated with any of the pre-defined
 section types for `ORKVisualConsentStep`. Ignored for `ORKConsentReviewStep` and
 for PDF generation.
 
 This image will be used in template rendering mode, tinted to the tint color.
 */
@property (nonatomic, copy, ORK_NULLABLE) UIImage *customImage;


/**
 A custom "Learn More" button title.
 
 The pre-defined section types have localized descriptive "Learn More" button
 titles for `ORKVisualConsentStep`. This property, if non-nil, overrides that
 default text.
 
 This string should be localized to the user's language.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *customLearnMoreButtonTitle;

/**
 A file URL to a custom transition animation video.
 
 Animations of the illustration between one screen and the next are provided
 by default for transitions between consecutive section `type` codes. Custom
 sections, and out-of-order transitions, may require custom animations.
 
 The animation loaded from this file URL will be played aspect fill in the
 illustration area, for forward transitions only. The video is rendered in
 template mode, with white treated as if it were transparent.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSURL *customAnimationURL;

@end

ORK_ASSUME_NONNULL_END

