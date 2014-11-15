//
//  RKResult_Private.h
//  ResearchKit
//
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <ResearchKit/ResearchKit_Private.h>

/**
 * @brief The RKDataResult contains result data in NSData format.
 */
@interface RKDataResult : RKResult

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

@interface RKResult(Archiving)

- (BOOL)addToArchive:(RKDataArchive *)archive error:(NSError * __autoreleasing *)error;

- (NSMutableDictionary *)_serializableDictionary;

@end

@interface RKQuestionResult(Internal)

+ (RKQuestionResult *)nullResultForQuestionStep:(RKQuestionStep *)questionStep;

@end

@interface RKDateAnswer(Internal)

+ (RKDateAnswer *)_dateAnswerFromPicker:(UIDatePicker *)picker withFormat:(RKDateAnswerFormat *)format;

- (NSDictionary *)_serializableDictionaryWithQuestionType:(RKSurveyQuestionType)questionType;

@end

