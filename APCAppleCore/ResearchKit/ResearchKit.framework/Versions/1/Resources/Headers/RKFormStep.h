//
//  RKFormStep.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


@interface RKFormStep : RKStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                              name:(NSString *)name
                             title:(NSString *)title
                          subtitle:(NSString*) subtitle;

/**
 * @brief Allow user to skip current step with no answer.
 * @note Default value is YES.
 */
@property (nonatomic) BOOL optional;

/**
 * @brief Form's title.
 */
@property (nonatomic, copy) NSString *title;

/**
 * @brief Form's SubTitle.
 */
@property (nonatomic, copy) NSString *subtitle;

/**
 * @brief Form's question item.
 */
@property (nonatomic, copy) NSArray/* <RKFormItem> */ *formItems;

@end


@interface RKFormItem : NSObject <NSSecureCoding>

- (instancetype)initWithIdentifier:(NSString*)identifier text:(NSString*)text answerFormat: (RKAnswerFormat*) answerFormat;

/**
 * @brief Question's identifier.
 */
@property (nonatomic, copy, readonly) NSString* identifier;

/**
 * @brief Short text about this from item.
 */
@property (nonatomic, copy, readonly) NSString *text;

/**
 * @brief Place holder for its field.
 * @warning Not applicable for boolean answer format.
 */
@property (nonatomic, copy) NSString *placeholder;

/**
 * @brief AnswerFormat object contains detailed information about an answer.
 * e.g. type, constraints, and choices.
 */
@property (nonatomic, strong, readonly) RKAnswerFormat* answerFormat;

@end