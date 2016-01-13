//
//  APCDataGroupsManager.h
//  APCAppCore
//
//  Created by Shannon Young on 1/12/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class APCUser, APCTableViewRow;

@interface APCDataGroupsManager : NSObject

@property (nonatomic, readonly) BOOL hasChanges;
@property (nonatomic, readonly) NSArray * _Nullable dataGroups;
@property (nonatomic, readonly) NSDictionary * _Nullable mapping;

- (instancetype)initWithDataGroups:(NSArray * _Nullable)dataGroups mapping:(NSDictionary * _Nullable)mapping;

- (BOOL)needsUserInfoDataGroups;
- (BOOL)isStudyControlGroup;
- (NSArray <APCTableViewRow *> * _Nullable)surveyItems;
- (void)setSurveyAnswerWithIdentifier:(NSString*)identifier selectedIndices:(NSArray*)selectedIndices;

@end

NS_ASSUME_NONNULL_END