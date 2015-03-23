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

@protocol ORKCustomActiveStepView;

ORK_ASSUME_NONNULL_BEGIN


@class ORKQuestionStepCustomView;


/**
 Protocol that custom question step custom views should implement.
 
 The question step view controller (`ORKQuestionStepViewController`) is normally
 the delegate of custom question step views.
 */
@protocol ORKQuestionStepCustomViewDelegate<NSObject>

- (void)customQuestionStepView:(ORKQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(ORK_NULLABLE id)answer;

@end

/**
 `ORKQuestionStepCustomView` is a base class for views that are used for
 `ORKQuestionStep` display in an `ORKQuestionStepViewController`.
 
 Custom question step views can subclass `ORKQuestionStepCustomView`. This is
 typically only of use if you are implementing a new answer format for the
 survey engine.
 
 Subclasses should implement `sizeThatFits:`, or include internal constraints or report
 an intrinsic content size to be allocated the space they require.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionStepCustomView : UIView

/// Custom question step view should report changes in its result
@property (nonatomic, weak, ORK_NULLABLE) id<ORKQuestionStepCustomViewDelegate> delegate;

/// The answer should be a JSON-serializable atomic type.
@property (nonatomic, copy, ORK_NULLABLE) id answer;

@end

@class ORKSurveyAnswerCell;
@interface ORKQuestionStepCellHolderView : ORKQuestionStepCustomView

@property (nonatomic, strong, ORK_NULLABLE) ORKSurveyAnswerCell *cell;

@end

ORK_ASSUME_NONNULL_END
