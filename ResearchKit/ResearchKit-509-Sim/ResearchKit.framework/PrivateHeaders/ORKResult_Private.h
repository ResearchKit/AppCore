//
//  ORKResult_Private.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

/**
 * @brief The ORKDataResult contains result data in NSData format.
 */
ORK_CLASS_AVAILABLE
@interface ORKDataResult : ORKResult

/**
 * @brief Result's contentType.
 */
@property (nonatomic, copy) NSString *contentType;

/**
 * @brief filename to use when archiving
 */
@property (nonatomic, copy) NSString *filename;

/**
 * @brief Data object attached to the result.
 */
@property (nonatomic, copy) NSData* data;

@end

@interface ORKResult(Archiving)

- (NSMutableDictionary *)_serializableDictionary;

@end

@interface ORKQuestionResult()

+ (Class)answerClass;

// For type invariant answer
- (void)setAnswer:(id)answer;
- (id)answer;

@end


