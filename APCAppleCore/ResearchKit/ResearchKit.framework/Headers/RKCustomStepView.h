//
//  RKCustomStepView.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@protocol RKCustomActiveStepView;


/**
 Protocol that custom question step views should implement.
 
 */

@class RKQuestionStepCustomView;

@protocol RKQuestionStepCustomViewDelegate<NSObject>

- (void)customQuestionStepView:(RKQuestionStepCustomView *)customQuestionStepView didChangeResult:(id)result;

@end

/*
 Custom step views should subclass RKCustomQuestionStepView
 They should implement sizeThatFits:, or include internal constraints or report
 an intrinsic content size to be allocated the space they require.
 */
@interface RKQuestionStepCustomView : UIView

// Custom question step view should report changes in its result
@property (nonatomic, weak) id<RKQuestionStepCustomViewDelegate> delegate;

// Result should be a JSON-serializable atomic type.
@property (nonatomic, copy) id result;

@end

