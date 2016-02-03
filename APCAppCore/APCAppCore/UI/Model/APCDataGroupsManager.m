//
//  APCDataGroupsManager.m
//  APCAppCore
//
// Copyright (c) 2015, Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "APCDataGroupsManager.h"
#import "APCAppCore.h"

NSString * const APCDataGroupsStepIdentifier = @"dataGroups";

NSString * const APCDataGroupsMappingItemsKey = @"items";
NSString * const APCDataGroupsMappingRequiredKey = @"required";
NSString * const APCDataGroupsMappingProfileKey = @"profile";
NSString * const APCDataGroupsMappingSurveyKey = @"survey";
NSString * const APCDataGroupsMappingQuestionsKey = @"questions";

NSString * const APCDataGroupsMappingSurveyTitleKey = @"title";
NSString * const APCDataGroupsMappingSurveyTextKey = @"text";
NSString * const APCDataGroupsMappingSurveyOptionalKey = @"optional";
NSString * const APCDataGroupsMappingSurveyIdentifierKey = @"identifier";
NSString * const APCDataGroupsMappingSurveyQuestionTypeKey = @"type";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapKey = @"valueMap";
NSString * const APCDataGroupsMappingSurveyQuestionTypeBoolean = @"boolean";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapValueKey = @"value";
NSString * const APCDataGroupsMappingSurveyQuestionValueMapGroupsKey = @"groups";

typedef NS_ENUM(NSUInteger, APCDataGroupsQuestionType) {
    APCDataGroupsQuestionTypeUnknown = 0,
    APCDataGroupsQuestionTypeBoolean
};

@interface APCDataGroupsQuestion : NSObject

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *text;
@property (nonatomic) BOOL optional;
@property (nonatomic) APCDataGroupsQuestionType questionType;
@property (nonatomic) NSArray *valueMap;

@property (nonatomic, readonly) NSArray <ORKTextChoice *> *textChoices;
@property (nonatomic, readonly) ORKFormItem *formItem;

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary;

@end

@interface APCDataGroupsStep : ORKFormStep

@property (nonatomic, readonly) NSArray <APCDataGroupsQuestion*> *questions;

- (instancetype _Nullable)initWithDictionaryRepresentation:(NSDictionary *  _Nullable)dictionary;

@end

@interface APCDataGroupsManager ()

@property (nonatomic, copy) NSSet *originalDataGroupsSet;
@property (nonatomic, strong) NSMutableSet *dataGroupsSet;

@property (nonatomic, readonly) APCDataGroupsStep *survey;
@property (nonatomic, readonly) APCDataGroupsStep *profile;

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
        _survey = [[APCDataGroupsStep alloc] initWithDictionaryRepresentation:_mapping[APCDataGroupsMappingSurveyKey]];
        _profile = [[APCDataGroupsStep alloc] initWithDictionaryRepresentation:_mapping[APCDataGroupsMappingProfileKey]];
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

- (ORKFormStep *)surveyStep {
    return self.survey;
}

- (NSArray <APCTableViewRow *> * _Nullable)surveyItems {
    
    if (self.profile == nil) {
        return nil;
    }

    NSMutableArray *result = [NSMutableArray new];
    for (APCDataGroupsQuestion *question in self.profile.questions) {

        // Create the item
        APCTableViewCustomPickerItem *item = [[APCTableViewCustomPickerItem alloc] init];
        item.questionIdentifier = question.identifier;
        item.reuseIdentifier = kAPCDefaultTableViewCellIdentifier;
        item.caption = question.text ?: self.profile.text;
        item.textAlignnment = NSTextAlignmentRight;
        
        // Get the choices
        item.pickerData = @[[question.textChoices valueForKey:NSStringFromSelector(@selector(text))]];
        
        // Set selected rows
        id selectedValue = [self selectedValueForQuestion:question];
        NSArray *valueOrder = [question.textChoices valueForKey:NSStringFromSelector(@selector(value))];
        NSUInteger idx = (selectedValue != nil) ? [valueOrder indexOfObject:selectedValue] : NSNotFound;
        if (idx != NSNotFound) {
            item.selectedRowIndices = @[@(idx)];
        }
        
        // Create row
        APCTableViewRow *row = [APCTableViewRow new];
        row.item = item;
        row.itemType = kAPCUserInfoItemTypeDataGroups;
        [result addObject:row];
    }
    
    return [result copy];
}

- (id)selectedValueForQuestion:(APCDataGroupsQuestion*)question {
    NSArray *valueMap = question.valueMap;
    if (self.dataGroups.count > 0) {
        NSSet *groupSet = [NSSet setWithArray:self.dataGroups];
        for (NSDictionary *map in valueMap) {
            NSMutableSet *mapSet = [NSMutableSet setWithArray:map[APCDataGroupsMappingSurveyQuestionValueMapGroupsKey]];
            [mapSet intersectSet:groupSet];
            if (mapSet.count > 0) {
                return map[APCDataGroupsMappingSurveyQuestionValueMapValueKey];
            }
        }
    }
    return nil;
}

- (void)setSurveyAnswerWithStepResult:(ORKStepResult *)stepResult {
    for (ORKResult *result in stepResult.results) {
        if ([result isKindOfClass:[ORKChoiceQuestionResult class]]) {
            ORKChoiceQuestionResult *choiceResult = (ORKChoiceQuestionResult *)result;

            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", APCDataGroupsMappingSurveyIdentifierKey, choiceResult.identifier];
            APCDataGroupsQuestion *question = [[self.survey.questions filteredArrayUsingPredicate:predicate] firstObject];
            
            NSArray *valueMap = question.valueMap;
            
            // Get the groups that are to be included based on the answer to this question
            NSPredicate *includePredicate = [NSPredicate predicateWithFormat:@"%K IN %@", APCDataGroupsMappingSurveyQuestionValueMapValueKey, choiceResult.choiceAnswers];
            NSArray *includeGroups = [[valueMap filteredArrayUsingPredicate:includePredicate] valueForKey:APCDataGroupsMappingSurveyQuestionValueMapGroupsKey];
            
            // Get the groups that are changing to be excluded (which are the groups mapped to
            // an aswer that was *not* selected
            NSPredicate *excludePredicate = [NSCompoundPredicate notPredicateWithSubpredicate:includePredicate];
            NSArray *excludeGroups = [[valueMap filteredArrayUsingPredicate:excludePredicate] valueForKey:APCDataGroupsMappingSurveyQuestionValueMapGroupsKey];
            
            // Remove data groups that are *not* in the selected subset
            for (NSArray *groups in excludeGroups) {
                [self.dataGroupsSet minusSet:[NSSet setWithArray:groups]];
            }
            
            // Add data groups that *are* in the selected subset
            for (NSArray *groups in includeGroups) {
                [self.dataGroupsSet unionSet:[NSSet setWithArray:groups]];
            }
        }
        else {
            NSAssert1(NO, @"Data groups survey question of class %@ is not handled.", [result class]);
        }
    }
}

- (void)setSurveyAnswerWithItem:(APCTableViewItem*)item {
    if ([item isKindOfClass:[APCTableViewCustomPickerItem class]]) {
        NSArray *selectedIndices = ((APCTableViewCustomPickerItem*)item).selectedRowIndices;
        NSAssert(selectedIndices.count <= 1, @"Data groups with multi-part picker are not implemented.");
        
        NSString *identifier = item.questionIdentifier;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", APCDataGroupsMappingSurveyIdentifierKey, identifier];
        APCDataGroupsQuestion *question = [[self.profile.questions filteredArrayUsingPredicate:predicate] firstObject];
        
        // Get all the groups that are defined by this question
        NSArray *groupsMap = [question.valueMap valueForKey:APCDataGroupsMappingSurveyQuestionValueMapGroupsKey];
        
        // build the include and exclude sets
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
        
        // Remove data groups that are *not* in the selected indices (and are instead associated
        // with a choice that was *not* selected)
        [self.dataGroupsSet minusSet:excludeSet];
        
        // Union data groups that *are* in the selected indices
        [self.dataGroupsSet unionSet:includeSet];
        
    }
    else {
        NSAssert1(NO, @"Data groups survey question of class %@ is not handled.", [item class]);
    }
}

- (ORKStepResult * _Nullable)stepResult {
    
    NSMutableArray *results = [NSMutableArray new];
    
    // For each question, look for a mapped answer
    for (APCDataGroupsQuestion *question in self.survey.questions) {
        id selectedValue = [self selectedValueForQuestion:question];
        if (selectedValue != nil) {
            ORKChoiceQuestionResult *questionResult = [[ORKChoiceQuestionResult alloc] initWithIdentifier:question.identifier];
            questionResult.choiceAnswers = @[selectedValue];
            [results addObject:questionResult];
        }
    }
    
    if (results.count == 0) {
        return nil;
    }
    
    ORKStepResult *stepResult = [[ORKStepResult alloc] initWithStepIdentifier:APCDataGroupsStepIdentifier results:results];
    return stepResult;
}

@end

@implementation APCDataGroupsStep

- (instancetype _Nullable)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
    if (dictionary == nil) {
        return nil;
    }
    
    self = [super initWithIdentifier:APCDataGroupsStepIdentifier];
    if (self) {
        
        // Data groups step is *not* optional by default
        self.optional = NO;
        
        // Set values from the dictionary
        [self setValuesForKeysWithDictionary:dictionary];
        
        if (self.questions.count == 0) {
            return nil;
        }
        
        // If there is only one question and no text, then set the text to the text of the
        // one question and nil out the question text.
        if ((self.text.length == 0) && (self.questions.count == 1)) {
            self.text = self.questions[0].text;
            self.questions[0].text = nil;
        }
        
        // set the form items from the questions
        self.formItems = [self.questions valueForKey:NSStringFromSelector(@selector(formItem))];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:APCDataGroupsMappingQuestionsKey]) {
        NSMutableArray *questions = [NSMutableArray new];
        for (NSDictionary *question in value) {
            // Get the currently selected choices
            [questions addObject:[[APCDataGroupsQuestion alloc] initWithDictionaryRepresentation:question]];
        }
        _questions = [questions copy];
    }
    else {
        [super setValue:value forKey:key];
    }
}

@end

@implementation APCDataGroupsQuestion

- (id)initWithDictionaryRepresentation:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
    if ([key isEqualToString:@"type"]) {
        if ([value isEqual:APCDataGroupsMappingSurveyQuestionTypeBoolean]) {
            _questionType = APCDataGroupsQuestionTypeBoolean;
        }
        else {
            NSAssert1(NO, @"Data groups survey question of type %@ is not handled.", value);
        }
    }
}

- (ORKFormItem *)formItem {
    // Get the default choices and add the skip choice if this question is optional
    ORKAnswerFormat *format = [ORKTextChoiceAnswerFormat
                               choiceAnswerFormatWithStyle:ORKChoiceAnswerStyleSingleChoice
                               textChoices:self.textChoices];
    ORKFormItem  *item = [[ORKFormItem alloc] initWithIdentifier:self.identifier
                                                            text:self.text
                                                    answerFormat:format];
    return item;
}

@synthesize textChoices = _textChoices;
- (NSArray <ORKTextChoice *> *) textChoices {
    if (_textChoices == nil) {
        if (self.questionType == APCDataGroupsQuestionTypeBoolean) {
            
            ORKTextChoice *yesChoice = [ORKTextChoice choiceWithText:NSLocalizedStringWithDefaultValue(@"YES", @"APCAppCore", APCBundle(), @"Yes", @"Yes") value:@YES];
            ORKTextChoice *noChoice = [ORKTextChoice choiceWithText:NSLocalizedStringWithDefaultValue(@"NO", @"APCAppCore", APCBundle(), @"No", @"No") value:@NO];
            
            // Use the ordering defined by the mapping
            if ([self.valueMap[0][APCDataGroupsMappingSurveyQuestionValueMapValueKey] boolValue]) {
                _textChoices = @[yesChoice, noChoice];
            }
            else {
                _textChoices = @[noChoice, yesChoice];
            }
            
            if (self.optional) {
                ORKTextChoice *skipChoice = [ORKTextChoice choiceWithText:NSLocalizedStringWithDefaultValue(@"APC_SKIP_CHOICE", @"APCAppCore", APCBundle(), @"Prefer not to answer", @"Choice text for skipping a question") value:@(NSNotFound)];
                _textChoices = [_textChoices arrayByAddingObject:skipChoice];
            }
            
        }
        else {
            NSAssert1(NO, @"Data groups survey question of type %@ is not handled.", @(self.questionType));
        }
    }
    return _textChoices;
}

@end
