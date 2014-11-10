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
 * @brief filename to use when archiving
 */
@property (nonatomic, copy) NSString *filename;

/**
 * @brief Data object attached to the result.
 */
@property (nonatomic, copy) NSData* data;

@end

@interface RKResult(Archiving)

+ (instancetype)resultForRecorder:(RKRecorder *)recorder;

- (BOOL)addToArchive:(RKDataArchive *)archive error:(NSError * __autoreleasing *)error;

@end

@interface RKQuestionResult(Internal)

+ (RKQuestionResult *)nullResultForQuestionStep:(RKQuestionStep *)questionStep;

@end

@interface RKEditableResult(Internal)

- (NSMutableDictionary *)_serializableDictionary;

@end
