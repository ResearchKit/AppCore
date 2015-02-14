//
//  RKSTResult_Private.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

/**
 * @brief The RKSTDataResult contains result data in NSData format.
 */
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTDataResult : RKSTResult

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

@interface RKSTResult(Archiving)

- (BOOL)addToArchive:(RKSTDataArchive *)archive error:(NSError * __autoreleasing *)error;

- (NSMutableDictionary *)_serializableDictionary;

@end

@interface RKSTQuestionResult()

+ (Class)answerClass;

// For type invariant answer
- (void)setAnswer:(id)answer;
- (id)answer;

@end


