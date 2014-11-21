//
//  RKFormStep.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


@interface RKFormStep : RKStep

- (instancetype)initWithIdentifier:(NSString *)identifier
                             title:(NSString *)title
                          subtitle:(NSString*) subtitle;

/**
 * @brief Form's question item.
 */
@property (nonatomic, copy) NSArray/* <RKFormItem> */ *formItems;

@end


@interface RKFormItem : NSObject <NSSecureCoding,NSCopying>

- (instancetype)initWithIdentifier:(NSString *)identifier text:(NSString *)text answerFormat:(RKAnswerFormat *) answerFormat;

/**
 * @brief Question's identifier.
 */
@property (nonatomic, copy, readonly) NSString* identifier;

/**
 * @brief Text describing this form item.
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
@property (nonatomic, copy, readonly) RKAnswerFormat* answerFormat;

@end