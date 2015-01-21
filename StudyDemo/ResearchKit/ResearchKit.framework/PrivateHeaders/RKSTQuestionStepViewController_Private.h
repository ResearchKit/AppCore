//
//  RKSTQuestionStepViewController_Private.h
//  Itasca
//
//  Created by John Earl on 10/29/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

@interface RKSTQuestionStepViewController ()<RKSTQuestionStepCustomViewDelegate>

/**
 * @brief Provide a custom question view
 * If a question requires a custom control for data entry, provide a suitable
 * custom step view. This view should provide sizeThatFits: or autolayout
 * constraints which determine the vertical space required.
 */
@property (nonatomic, strong) RKSTQuestionStepCustomView *customQuestionView;


@end
