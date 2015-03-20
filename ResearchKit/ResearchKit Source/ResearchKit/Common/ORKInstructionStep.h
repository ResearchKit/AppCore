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
 An `ORKInstructionStep` is used to give the participant instructions for, or
 during, a task.
 
 Instruction steps can be used for an introduction, or for instructions in the middle
 of a task, or for a final message at the completion of a task to indicate
 next steps.
 
 See also: For a more positive completion indication, consider `ORKCompletionStep`.
 */
ORK_CLASS_AVAILABLE
@interface ORKInstructionStep : ORKStep

/**
 Additional detailed explanation for the instruction.
 
 This text is displayed below the `text` property.
 */
@property (nonatomic, copy, ORK_NULLABLE) NSString *detailText;

/**
 An image providing visual context to the instruction.
 
 This image is displayed with aspect fit. The screen area
 available for this image may vary, depending on the device. For exact
 metrics, see `ORKScreenMetricIllustrationHeight` in the codebase.
 */
@property (nonatomic, copy, ORK_NULLABLE) UIImage *image;

@end

ORK_ASSUME_NONNULL_END
