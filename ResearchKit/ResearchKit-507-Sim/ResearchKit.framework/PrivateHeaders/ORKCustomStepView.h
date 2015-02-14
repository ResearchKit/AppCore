//
//  ORKCustomStepView.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@protocol ORKCustomActiveStepView;


/**
 Protocol that custom question step views should implement.
 
 */

@class ORKQuestionStepCustomView;

@protocol ORKQuestionStepCustomViewDelegate<NSObject>

- (void)customQuestionStepView:(ORKQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(id)answer;

@end

/*
 Custom step views should subclass ORKCustomQuestionStepView
 They should implement sizeThatFits:, or include internal constraints or report
 an intrinsic content size to be allocated the space they require.
 */
ORK_CLASS_AVAILABLE
@interface ORKQuestionStepCustomView : UIView

// Custom question step view should report changes in its result
@property (nonatomic, weak) id<ORKQuestionStepCustomViewDelegate> delegate;

// Answer should be a JSON-serializable atomic type.
@property (nonatomic, copy) id answer;

@end

