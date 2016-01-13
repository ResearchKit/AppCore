//
//  APCDataGroupsManager.m
//  APCAppCore
//
//  Created by Shannon Young on 1/12/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#import "APCDataGroupsManager.h"
#import "APCAppCore.h"

NSString * const APCDataGroupsMappingItemsKey = @"items";
NSString * const APCDataGroupsMappingRequiredKey = @"required";
NSString * const APCDataGroupsMappingQuestionsKey = @"questions";

NSString * const APCDataGroupsMappingSurveyQuestionIdentifierKey = @"identifier";
NSString * const APCDataGroupsMappingSurveyQuestionTypeKey = @"type";
NSString * const APCDataGroupsMappingSurveyQuestionPromptKey = @"prompt";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapKey = @"valueMap";
NSString * const APCDataGroupsMappingSurveyQuestionTypeBoolean = @"boolean";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapValueKey = @"value";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapGroupsKey = @"groups";

@interface APCDataGroupsManager ()

@property (nonatomic, copy) NSSet *originalDataGroupsSet;
@property (nonatomic, strong) NSMutableSet *dataGroupsSet;

@end

@implementation APCDataGroupsManager

+ (NSString*)pathForDataGroupsMapping {
    return [[APCAppDelegate sharedAppDelegate] pathForResource:@"DataGroupsMapping" ofType:@"json"];
}

+ (NSDictionary*)defaultMapping {
    static NSDictionary * _dataGroupMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [self pathForDataGroupsMapping];
        NSData *json = [NSData dataWithContentsOfFile:path];
        if (json) {
            NSError *parseError;
            _dataGroupMapping = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&parseError];
            if (parseError) {
                NSLog(@"Error parsing data group mapping: %@", parseError);
            }
        }
        
    });
    return _dataGroupMapping;
}

- (instancetype)initWithDataGroups:(NSArray *)dataGroups mapping:(NSDictionary*)mapping {
    self = [super init];
    if (self) {
        _mapping = [mapping copy] ?: [[self class] defaultMapping];
        _originalDataGroupsSet = (dataGroups.count > 0) ? [NSSet setWithArray:dataGroups] : [NSSet new];
        _dataGroupsSet = (dataGroups.count > 0) ? [NSMutableSet setWithArray:dataGroups] : [NSMutableSet new];
    }
    return self;
}

- (NSArray *)dataGroups {
    return [self.dataGroupsSet allObjects];
}

- (BOOL)hasChanges {
    return ![self.dataGroupsSet isEqualToSet:self.originalDataGroupsSet];
}

- (BOOL)needsUserInfoDataGroups {
    if ([self.mapping[APCDataGroupsMappingRequiredKey] boolValue]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"group_name IN %@", self.dataGroups];
        return [[self fiteredDataGroupsUsingPredicate:predicate] count] == 0;
    }
    return NO;
}

- (BOOL)isStudyControlGroup {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(group_name IN %@) AND (is_control_group = YES)", self.dataGroups];
    return [[self fiteredDataGroupsUsingPredicate:predicate] count] > 0;
}

- (NSArray <NSString *> * _Nullable)fiteredDataGroupsUsingPredicate:(NSPredicate *)predicate {
    return [self.mapping[APCDataGroupsMappingItemsKey] filteredArrayUsingPredicate:predicate];
}

- (NSArray <APCTableViewRow *> * _Nullable)surveyItems {
    
    NSArray *questions = self.mapping[APCDataGroupsMappingQuestionsKey];
    if (questions.count == 0) {
        return nil;
    }

    NSMutableArray *result = [NSMutableArray new];
    for (NSDictionary *question in questions) {
        NSString *questionType = question[APCDataGroupsMappingSurveyQuestionTypeKey];
        if ([questionType isEqualToString:APCDataGroupsMappingSurveyQuestionTypeBoolean])
        {
            APCTableViewCustomPickerItem *item = [[APCTableViewCustomPickerItem alloc] init];
            item.identifier = question[APCDataGroupsMappingSurveyQuestionIdentifierKey];
            item.caption = question[APCDataGroupsMappingSurveyQuestionPromptKey];
            item.textAlignnment = NSTextAlignmentRight;
            
            // Set the values to YES or NO
            NSArray *valueMap = question[APCDataGroupsMappingSurveyQuestionValueMapKey];
            NSString *yes = NSLocalizedStringWithDefaultValue(@"YES", @"APCAppCore", APCBundle(), @"Yes", @"Yes");
            NSString *no = NSLocalizedStringWithDefaultValue(@"NO", @"APCAppCore", APCBundle(), @"No", @"No");
            if ([valueMap[0][APCDataGroupsMappingSurveyQuestionValueMapValueKey] boolValue]) {
                item.pickerData = @[yes, no];
            }
            else {
                item.pickerData = @[no, yes];
            }
            
            // Set selected rows
            NSString *selectedValue = [[self selectedValuesForMap:valueMap] firstObject];
            if (selectedValue != nil) {
                item.selectedRowIndices = [selectedValue boolValue] ? @[@0] : @[@1];
            }
            
            APCTableViewRow *row = [APCTableViewRow new];
            row.item = item;
            row.itemType = kAPCUserInfoItemTypeDataGroups;
            [result addObject:row];
        }
        else
        {
            NSAssert1(NO, @"Data groups survey question of type %@ is not handled.", questionType);
        }
    }
    
    return [result copy];
}

- (NSArray *)selectedValuesForMap:(NSArray*)valueMap {
    
    if (self.dataGroups.count == 0) {
        return nil;
    }
    
    NSMutableArray *values = [NSMutableArray new];
    NSSet *groupSet = [NSSet setWithArray:self.dataGroups];
    for (NSDictionary *map in valueMap) {
        NSMutableSet *mapSet = [NSMutableSet setWithArray:map[APCDataGroupsMappingSurveyQuestionValueMapGroupsKey]];
        [mapSet intersectSet:groupSet];
        if (mapSet.count > 0) {
            [values addObject:map[APCDataGroupsMappingSurveyQuestionValueMapValueKey]];
        }
    }
    
    return values;
}

- (void)setSurveyAnswerWithIdentifier:(NSString*)identifier selectedIndices:(NSArray*)selectedIndices {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", APCDataGroupsMappingSurveyQuestionIdentifierKey, identifier];
    NSDictionary *question = [[self.mapping[APCDataGroupsMappingQuestionsKey] filteredArrayUsingPredicate:predicate] firstObject];
    
    // Get all the groups that are defined by this question
    NSArray *groupsMap = [question[APCDataGroupsMappingSurveyQuestionValueMapKey] valueForKey:APCDataGroupsMappingSurveyQuestionValueMapGroupsKey];
    
    NSMutableSet *excludeSet = [NSMutableSet new];
    NSMutableSet *includeSet = [NSMutableSet new];
    for (NSUInteger idx = 0; idx < groupsMap.count; idx++) {
        if ([selectedIndices containsObject:@(idx)]) {
            [includeSet addObjectsFromArray:groupsMap[idx]];
        }
        else {
            [excludeSet addObjectsFromArray:groupsMap[idx]];
        }
    }
    
    // Remove data groups that are *not* in the selected indices
    [self.dataGroupsSet minusSet:excludeSet];
    
    // Union data groups that *are* in the selected indices
    [self.dataGroupsSet unionSet:includeSet];
}

@end
