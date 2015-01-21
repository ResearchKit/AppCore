//
//  RKSTCustomStepView.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@protocol RKSTCustomActiveStepView;


/**
 Protocol that custom question step views should implement.
 
 */

@class RKSTQuestionStepCustomView;

@protocol RKSTQuestionStepCustomViewDelegate<NSObject>

- (void)customQuestionStepView:(RKSTQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(id)answer;

@end

/*
 Custom step views should subclass RKCustomQuestionStepView
 They should implement sizeThatFits:, or include internal constraints or report
 an intrinsic content size to be allocated the space they require.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTQuestionStepCustomView : UIView

// Custom question step view should report changes in its result
@property (nonatomic, weak) id<RKSTQuestionStepCustomViewDelegate> delegate;

// Answer should be a JSON-serializable atomic type.
@property (nonatomic, copy) id answer;

@end

