//
//  RKSTFormStep.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTFormStep : RKSTStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                              text:(NSString *)text;

/**
 * @brief Form's question item.
 */
@property (nonatomic, copy) NSArray/* <RKSTFormItem> */ *formItems;

@end


RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTFormItem : NSObject <NSSecureCoding, NSCopying>

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(RKSTAnswerFormat *)answerFormat;

/**
 * @brief A section title is the title of on the section header. Also it is  a indication of begining of a new table section.
 */
- (instancetype)initWithSectionTitle:(NSString *)sectionTitle;

/**
 * @brief Question's identifier.
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 * @brief Text describing this form item.
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * @brief Place holder for its field.
 * @warning Not applicable for boolean, single choice, and multiple choice answer format.
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 * @brief AnswerFormat object contains detailed information about an answer.
 * e.g. type, constraints, and choices.
 */
@property (nonatomic, copy, readonly) RKSTAnswerFormat *answerFormat;

@end
