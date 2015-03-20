/*
 Copyright (c) 2015, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKQuestionStepViewController.h"
#import "ORKDefines_Private.h"
#import "ORKResult.h"
#import "ORKTaskViewController_Internal.h"
#import "ORKSkin.h"
#import "ORKStepViewController_Internal.h"

#import "ORKChoiceViewCell.h"
#import "ORKSurveyAnswerCellForScale.h"
#import "ORKSurveyAnswerCellForNumber.h"
#import "ORKSurveyAnswerCellForText.h"
#import "ORKSurveyAnswerCellForPicker.h"
#import "ORKSurveyAnswerCellForImageSelection.h"
#import "ORKAnswerFormat.h"
#import "ORKHelpers.h"
#import "ORKCustomStepView.h"
#import "ORKVerticalContainerView.h"
#import "ORKQuestionStep_Internal.h"
#import "ORKAnswerFormat_Internal.h"
#import "ORKQuestionStepViewController_Private.h"
#import "ORKVerticalContainerView_Internal.h"
#import "ORKTableContainerView.h"
#import "ORKStep_Private.h"
#import "ORKTextChoiceCellGroup.h"
#import "ORKStepHeaderView_Internal.h"
#import "ORKNavigationContainerView_Internal.h"
#import "ORKQuestionStepView.h"

typedef NS_ENUM(NSInteger, ORKQuestionSection)
{
    ORKQuestionSectionSpace1 = 0,
    ORKQuestionSectionAnswer = 1,
    ORKQuestionSectionSpace2 = 2,
    ORKQuestionSection_COUNT
};



@interface ORKQuestionStepViewController () <UITableViewDataSource,UITableViewDelegate, ORKSurveyAnswerCellDelegate>{
    
    id _answer;
    
    ORKTableContainerView *_tableContainer;
    ORKStepHeaderView *_headerView;
    ORKNavigationContainerView *_continueSkipView;
    ORKAnswerDefaultSource *_defaultSource;
    
    NSCalendar *_savedSystemCalendar;
    NSTimeZone *_savedSystemTimeZone;
    
    ORKTextChoiceCellGroup *_choiceCellGroup;
    
    id _defaultAnswer;
    
    BOOL _visible;
}


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ORKQuestionStepView *questionView;

@property (nonatomic, strong) ORKAnswerFormat *answerFormat;
@property (nonatomic, copy) id<NSCopying, NSObject, NSCoding> answer;

@property (nonatomic, strong) ORKContinueButton *continueActionButton;

@property (nonatomic, strong) ORKSurveyAnswerCell *answerCell;

@property (nonatomic, readonly) UILabel *questionLabel;
@property (nonatomic, readonly) UILabel *promptLabel;

// If haveChangedAnswer, then a new defaultAnswer should not change the answer
@property (nonatomic, assign) BOOL haveChangedAnswer;

@end


@implementation ORKQuestionStepViewController

- (void)_initializeInternalButtonItems
{
    [super _initializeInternalButtonItems];
    self.internalSkipButtonItem.title = ORKLocalizedString(@"BUTTON_SKIP_QUESTION", nil);
}

- (instancetype)initWithStep:(ORKStep *)step result:(ORKResult *)result {
    self = [self initWithStep:step];
    if (self) {
		ORKStepResult *stepResult = (ORKStepResult *)result;
		if (stepResult && [stepResult results].count > 0) {
            ORKQuestionResult *questionResult = [[stepResult results] firstObject];
            id answer = [questionResult answer];
            if (questionResult != nil && answer == nil) {
                answer = ORKNullAnswerValue();
            }
			self.answer = answer;
		}
    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step {
    
    self = [super initWithStep:step];
    if (self) {
        _defaultSource = [ORKAnswerDefaultSource sourceWithHealthStore:[HKHealthStore new]];
    }
    return self;
}

- (void)_stepDidChange
{
    [super _stepDidChange];
    _answerFormat = [self.questionStep _impliedAnswerFormat];
    
    self.haveChangedAnswer = NO;
    
    if ([self isViewLoaded])
    {
        [_tableContainer removeFromSuperview];
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
        _tableView = nil;
        _headerView = nil;
        _continueSkipView = nil;
        
        [_questionView removeFromSuperview];
        _questionView = nil;
        
        if ([self.questionStep _formatRequiresTableView] && ! _customQuestionView)
        {
            _tableContainer = [[ORKTableContainerView alloc] initWithFrame:self.view.bounds];
            
            // Create a new one (with correct style)
            _tableView = _tableContainer.tableView;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            
            [self.view addSubview:_tableContainer];
            
            _headerView = _tableContainer.stepHeaderView;
            _headerView.captionLabel.useSurveyMode = self.step.useSurveyMode;
            _headerView.captionLabel.text = self.questionStep.title;
            _headerView.instructionLabel.text = self.questionStep.text;
            _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
            
            _continueSkipView = _tableContainer.continueSkipContainerView;
            _continueSkipView.skipButtonItem = self.skipButtonItem;
            _continueSkipView.continueEnabled = [self continueButtonEnabled];
            _continueSkipView.continueButtonItem = self.continueButtonItem;
            _continueSkipView.optional = self.step.optional;
            [_tableContainer setNeedsLayout];
        }
        else if (self.step)
        {
            _questionView = [ORKQuestionStepView new];
            _questionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
            _questionView.questionStep = [self questionStep];
            [self.view addSubview:_questionView];
            
            if (_customQuestionView)
            {
                _questionView.questionCustomView = _customQuestionView;
                _customQuestionView.delegate = self;
                _customQuestionView.answer = [self answer];
            }
            else
            {
                ORKQuestionStepCellHolderView *holder = [ORKQuestionStepCellHolderView new];
                holder.delegate = self;
                holder.cell = [self _answerCellForTableView:nil];
                [holder addConstraints:[holder.cell suggestedCellHeightConstraintsForView:self.parentViewController.view]];
                holder.answer = [self answer];
                
                _questionView.questionCustomView = holder;
            }
            
            [_questionView setTranslatesAutoresizingMaskIntoConstraints:NO];
            _questionView.continueSkipContainer.continueButtonItem = self.continueButtonItem;
            _questionView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
            _questionView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
            _questionView.continueSkipContainer.continueEnabled = [self continueButtonEnabled];
            
            NSMutableArray *constraints = [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[s]|" options:0 metrics:nil views:@{@"s":_questionView}]];
            [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tg][s][bg]" options:0 metrics:nil views:@{@"s":_questionView,@"tg":self.topLayoutGuide,@"bg":self.bottomLayoutGuide}]];
            for (NSLayoutConstraint *constraint in constraints)
            {
                constraint.priority = UILayoutPriorityRequired;
            }
            [self.view addConstraints:constraints];
            
        }
        
    }
    
    
    if ([self allowContinue] == NO) {
        self.continueButtonItem  = self.internalContinueButtonItem;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _stepDidChange];
    
}

- (void)_showValidityAlertWithMessage:(NSString *)text {
    // Ignore if our answer is null
    if (self.answer == ORKNullAnswerValue()) {
        return;
    }
    
    [super _showValidityAlertWithMessage:text];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_tableView) {
        [self.taskViewController setRegisteredScrollView:_tableView];
    }
    if (_questionView) {
        [self.taskViewController setRegisteredScrollView:_questionView];
    }
    
    NSMutableSet *types = [NSMutableSet set];
    ORKAnswerFormat *format = [[self questionStep] answerFormat];
    HKObjectType *objType = [format _healthKitObjectType];
    if (objType)
    {
        [types addObject:objType];
    }
    
    BOOL scheduledRefresh = NO;
    if ([types count])
    {
        NSSet *alreadyRequested = [[self taskViewController] _requestedHealthTypesForRead];
        if (! [types isSubsetOfSet:alreadyRequested])
        {
            scheduledRefresh = YES;
            [_defaultSource.healthStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError *error) {
                if (success)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self _refreshDefaults];
                    });
                }
            }];
        }
    }
    if (! scheduledRefresh) {
        [self _refreshDefaults];
    }
}

- (void)_answerDidChange {
    if ([self.questionStep _formatRequiresTableView] && ! _customQuestionView)
    {
        [self.tableView reloadData];
    }
    else
    {
        
        if (_customQuestionView)
        {
            _customQuestionView.answer = _answer;
        }
        else
        {
            ORKQuestionStepCellHolderView *holder = (ORKQuestionStepCellHolderView *)_questionView.questionCustomView;
            holder.answer = _answer;
            [self.answerCell setAnswer:_answer];
        }
    }
    [self _updateButtonStates];
}

- (void)_refreshDefaults {
    [_defaultSource fetchDefaultValueForAnswerFormat:[[self questionStep] answerFormat] handler:^(id defaultValue, NSError *error) {
        if (defaultValue != nil || error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _defaultAnswer = defaultValue;
                [self _defaultAnswerDidChange];
            });
        } else {
            ORK_Log_Debug(@"Error fetching default: %@", error);
        }
    }];
}

- (void)_defaultAnswerDidChange
{
    id defaultAnswer = _defaultAnswer;
    if (! [self _hasAnswer] && (self.answer != ORKNullAnswerValue()) && defaultAnswer && ! self.haveChangedAnswer)
    {
        _answer = defaultAnswer;
        
        [self _answerDidChange];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Delay creating the date picker until the view has appeared (to avoid animation stutter)
    ORKSurveyAnswerCellForPicker *cell = (ORKSurveyAnswerCellForPicker *)[(ORKQuestionStepCellHolderView *)_questionView.questionCustomView cell];
    if ([cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]])
    {
        [cell loadPicker];
    }
    
    _visible = YES;
    
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.navigationItem.leftBarButtonItem);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _visible = NO;
}

- (void)setCustomQuestionView:(ORKQuestionStepCustomView *)customQuestionView
{
    [_customQuestionView removeFromSuperview];
    _customQuestionView = customQuestionView;
    if (! [[_customQuestionView constraints] count])
    {
        CGSize requiredSize = [_customQuestionView sizeThatFits:(CGSize){self.view.bounds.size.width,CGFLOAT_MAX}];
        
        NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_customQuestionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:requiredSize.width];
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_customQuestionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:requiredSize.height];
        
        widthConstraint.priority = UILayoutPriorityDefaultLow;
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [_customQuestionView addConstraints:@[widthConstraint, heightConstraint]];
        [_customQuestionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self _stepDidChange];
}

- (void)_updateButtonStates
{
    if ([self.questionStep _isFormatImmediateNavigation]) {
        _continueSkipView.neverHasContinueButton = YES;
        _continueSkipView.continueButtonItem = nil;
    }
    _questionView.continueSkipContainer.continueEnabled = [self continueButtonEnabled];
    _continueSkipView.continueEnabled = [self continueButtonEnabled];
}

// Override to monitor button title change
- (void)setContinueButtonItem:(UIBarButtonItem *)continueButtonItem {
    [super setContinueButtonItem:continueButtonItem];
    _questionView.continueSkipContainer.continueButtonItem = continueButtonItem;
    _continueSkipView.continueButtonItem = continueButtonItem;
    [self _updateButtonStates];
}

- (void)setLearnMoreButtonItem:(UIBarButtonItem *)learnMoreButtonItem
{
    [super setLearnMoreButtonItem:learnMoreButtonItem];
    _headerView.learnMoreButtonItem = self.learnMoreButtonItem;
    _questionView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
}

- (void)setSkipButtonItem:(UIBarButtonItem *)skipButtonItem
{
    [super setSkipButtonItem:skipButtonItem];
    
    _questionView.continueSkipContainer.skipButtonItem = self.skipButtonItem;
    _continueSkipView.skipButtonItem = self.skipButtonItem;
    [self _updateButtonStates];
    
}

- (ORKStepResult *)result {
    ORKStepResult *sResult = [super result];
    ORKQuestionStep *questionStep = self.questionStep;
    
    ORKQuestionResult *result = [questionStep.answerFormat _resultWithIdentifier:(__ORK_NONNULL NSString *)questionStep.identifier answer:self.answer];
    ORKAnswerFormat *impliedAnswerFormat = [questionStep _impliedAnswerFormat];
    
    if ([impliedAnswerFormat isKindOfClass:[ORKDateAnswerFormat class]])
    {
        ORKDateQuestionResult *dqr = (ORKDateQuestionResult *)result;
        if (dqr.dateAnswer) {
            NSCalendar *usedCalendar = [(ORKDateAnswerFormat *)impliedAnswerFormat calendar]? :_savedSystemCalendar;
            dqr.calendar = [NSCalendar calendarWithIdentifier:usedCalendar.calendarIdentifier?:[NSCalendar currentCalendar].calendarIdentifier];
            dqr.timeZone = _savedSystemTimeZone? : [NSTimeZone systemTimeZone];
        }
    } else if ([impliedAnswerFormat isKindOfClass:[ORKNumericAnswerFormat class]]) {
        ORKNumericQuestionResult *nqr = (ORKNumericQuestionResult *)result;
        nqr.unit = (__ORK_NONNULL NSString *)[(ORKNumericAnswerFormat *)impliedAnswerFormat unit];
    }
    
    result.startDate = sResult.startDate;
    result.endDate = sResult.endDate;
    
    sResult.results = @[result];
    
    return sResult;
}


#pragma mark - Internal

- (ORKQuestionStep *)questionStep {
    assert(!self.step || [self.step isKindOfClass:[ORKQuestionStep class]]);
    return (ORKQuestionStep *)self.step;
}

- (BOOL)_hasAnswer {
    return !(self.answer == nil || (self.answer == ORKNullAnswerValue()) || ([self.answer isKindOfClass:[NSArray class]] && [(NSArray *)self.answer count] == 0) );
}

- (void)saveAnswer:(id)answer {
    self.answer = answer;
    _savedSystemCalendar = [NSCalendar currentCalendar];
    _savedSystemTimeZone = [NSTimeZone systemTimeZone];
    [self _notifyDelegateOnResultChange];
}

- (void)skipForward {
    // Null out the answer before proceeding
    [self saveAnswer:ORKNullAnswerValue()];
    ORKSurveyAnswerCell *cell = self.answerCell;
    cell.answer = ORKNullAnswerValue();
    
    [super skipForward];
}

- (void)_notifyDelegateOnResultChange {
    
    [super _notifyDelegateOnResultChange];
    
    if (self.hasNextStep == NO) {
        self.continueButtonItem = self.internalDoneButtonItem;
    } else {
        self.continueButtonItem = self.internalContinueButtonItem;
    }
    
    self.skipButtonItem = self.internalSkipButtonItem;
    if (! self.questionStep.optional)
    {
        self.skipButtonItem = nil;
    }

    if ([self allowContinue] == NO) {
        self.continueButtonItem  = self.internalContinueButtonItem;
    }
    
    [self.tableView reloadData];
}

- (id<NSCopying, NSCoding, NSObject>)answer {
    
    if (self.questionStep.questionType == ORKQuestionTypeMultipleChoice && (_answer == nil || _answer == ORKNullAnswerValue())) {
        _answer = [NSMutableArray array];
    }
    return _answer;
}

- (void)setAnswer:(id)answer
{
    _answer = answer;
}

- (BOOL)continueButtonEnabled {
    return ([self _hasAnswer] || (self.questionStep.optional && ! self.skipButtonItem));
}

- (BOOL)allowContinue {
    return !(self.questionStep.optional == NO && [self _hasAnswer] == NO);
}


#pragma mark - ORKQuestionStepCustomViewDelegate

- (void)customQuestionStepView:(ORKQuestionStepCustomView *)customQuestionStepView didChangeAnswer:(id)answer;
{
    [self saveAnswer:answer];
    self.haveChangedAnswer = YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return ORKQuestionSection_COUNT;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == ORKQuestionSectionSpace1 || section == ORKQuestionSectionSpace2) {
        return 1;
    }
    
    ORKAnswerFormat *impliedAnswerFormat = [_answerFormat _impliedAnswerFormat];
    
    if (section == ORKQuestionSectionAnswer) {
        
        if (_choiceCellGroup == nil) {
            _choiceCellGroup = [[ORKTextChoiceCellGroup alloc] initWithTextChoiceAnswerFormat:(ORKTextChoiceAnswerFormat *)impliedAnswerFormat
                                                                                       answer:self.answer
                                                                           beginningIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                                                                          immediateNavigation:[self.questionStep _isFormatImmediateNavigation]];
        }
        
        return _choiceCellGroup.size;
       
    }
        
    return 0;
}


- (ORKSurveyAnswerCell *)_answerCellForTableView:(UITableView *)tableView
{
    static NSDictionary *typeAndCellMapping = nil;
    static NSString *identifier = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeAndCellMapping = @{@(ORKQuestionTypeScale): [ORKSurveyAnswerCellForScale class],
                               @(ORKQuestionTypeDecimal) : [ORKSurveyAnswerCellForNumber class],
                               @(ORKQuestionTypeText) : [ORKSurveyAnswerCellForText class],
                               @(ORKQuestionTypeTimeOfDay) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDate) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeDateAndTime) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeTimeInterval) : [ORKSurveyAnswerCellForPicker class],
                               @(ORKQuestionTypeInteger) : [ORKSurveyAnswerCellForNumber class]};
    });
    
    
    // SingleSelectionPicker Cell && Other Cells
    Class class = typeAndCellMapping[@(self.questionStep.questionType)];
    
    if([self.questionStep _isFormatChoiceWithImageOptions])
    {
        class = [ORKSurveyAnswerCellForImageSelection class];
    }
    else if ([self.questionStep _isFormatTextfield])
    {
        // Override for single-line text entry
        class = [ORKSurveyAnswerCellForTextField class];
    }
    else if ([[self.questionStep _impliedAnswerFormat] isKindOfClass:[ORKValuePickerAnswerFormat class]]) {
        class = [ORKSurveyAnswerCellForPicker class];
    }
    
    identifier = NSStringFromClass(class);
    
    NSAssert(class != nil, @"class should not be nil");
    
    ORKSurveyAnswerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) { 
        cell = [[class alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier step:[self questionStep] answer:self.answer delegate:self];
    }
    
    self.answerCell = cell;
    
    
    if ([self.questionStep _isFormatTextfield] ||
        [cell isKindOfClass:[ORKSurveyAnswerCellForScale class]] ||
        [cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]]) {
        cell.separatorInset = UIEdgeInsetsMake(0, self.view.bounds.size.width, 0, 0);
    }

    if ([cell isKindOfClass:[ORKSurveyAnswerCellForPicker class]] && _visible)
    {
        [(ORKSurveyAnswerCellForPicker *)cell loadPicker];
    }
    
    return cell;
}

// Row display. Implementers should *always *try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.layoutMargins = UIEdgeInsetsZero;
    
    if (indexPath.section == ORKQuestionSectionSpace1 || indexPath.section == ORKQuestionSectionSpace2) {
        static NSString * SpaceIdentifier = @"Space";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SpaceIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SpaceIdentifier];
        }
        
        return cell;
    }
    
    
    //////////////////////////////////
    // Section for Answer Area
    //////////////////////////////////
    
    static NSString *identifier = nil;
    //id answer = self.answer;
    
    assert (self.questionStep._isFormatFitsChoiceCells);
    
    
    identifier = [NSStringFromClass([self class]) stringByAppendingFormat:@"%@", @(indexPath.row)];
    
    ORKChoiceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [_choiceCellGroup cellAtIndexPath:indexPath withReuseIdentifier:identifier];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.separatorInset = (UIEdgeInsets){.left=ORKStandardMarginForView(tableView)};
    
}

- (BOOL)_shouldContinue
{
    ORKSurveyAnswerCell *cell = self.answerCell;
    if (!cell)
    {
        return YES;
    }
    
    return [cell shouldContinue];
}

- (void)goForward {
    if (! [self _shouldContinue]) {
        return;
    }
    
    [self _notifyDelegateOnResultChange];
    [super goForward];
}

- (void)goBackward {
    
    [self _notifyDelegateOnResultChange];
    [super goBackward];
}

- (void)_continueAction:(id)sender {

    if (self.continueActionButton.enabled) {
        
        if (! [self _shouldContinue])
        {
            return;
        }
        
        
        ORKSuppressPerformSelectorWarning(
                                         [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
    }
    return;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section != ORKQuestionSectionAnswer)
    {
        return nil;
    }
    if (NO == self.questionStep._isFormatFitsChoiceCells) {
        return nil;
    }
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == ORKQuestionSectionAnswer;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [_choiceCellGroup didSelectCellAtIndexPath:indexPath];
    
    id answer = (self.questionStep.questionType == ORKQuestionTypeBoolean) ? [_choiceCellGroup answerForBoolean] :[_choiceCellGroup answer];
    
    [self saveAnswer:answer];
    self.haveChangedAnswer = YES;
    
    if ([self.questionStep _isFormatImmediateNavigation]) {
        // Proceed as continueButton tapped
        ORKSuppressPerformSelectorWarning(
                                         [self.continueButtonItem.target performSelector:self.continueButtonItem.action withObject:self.continueButtonItem];);
        
    } else {
        [_tableView beginUpdates];
        [_tableView endUpdates];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == ORKQuestionSectionSpace1 || indexPath.section == ORKQuestionSectionSpace2) {
        return 1;
    }
    
    CGFloat height = [ORKSurveyAnswerCell suggestedCellHeightForView:tableView];
    
    switch (self.questionStep.questionType) {
        case ORKQuestionTypeSingleChoice:
        case ORKQuestionTypeMultipleChoice:{
            if ([self.questionStep _isFormatFitsChoiceCells]) {
                height = [self heightForChoiceItemOptionAtIndex:indexPath.row];
            } else {
                height = [ORKSurveyAnswerCellForPicker suggestedCellHeightForView:tableView];
            }
        }
            break;
        case ORKQuestionTypeInteger:
        case ORKQuestionTypeDecimal:{
            height = [ORKSurveyAnswerCellForNumber suggestedCellHeightForView:tableView];
        }
            break;
        case ORKQuestionTypeText:{
            height = [ORKSurveyAnswerCellForText suggestedCellHeightForView:tableView];
        }
            break;
        case ORKQuestionTypeTimeOfDay:
        case ORKQuestionTypeTimeInterval:
        case ORKQuestionTypeDate:
        case ORKQuestionTypeDateAndTime:{
            height = [ORKSurveyAnswerCellForPicker suggestedCellHeightForView:tableView];
        }
            break;
        case ORKQuestionTypeScale:{
            height = [ORKSurveyAnswerCellForScale suggestedCellHeightForView:tableView];
        }
            break;
        default:{
            
        }
            break;
    }
    
    return height;
}

- (CGFloat)heightForChoiceItemOptionAtIndex:(NSInteger)index {
    
    ORKTextChoice *option = [[(ORKTextChoiceAnswerFormat *)_answerFormat textChoices] objectAtIndex:index];
    CGFloat height = [ORKChoiceViewCell suggestedCellHeightForShortText:option.text LongText:option.detailText inTableView:_tableView];
    return height;
}

#pragma mark - ORKSurveyAnswerCellDelegate
- (void)answerCell:(ORKSurveyAnswerCell *)cell answerDidChangeTo:(id)answer dueUserAction:(BOOL)dueUserAction {
    [self saveAnswer:answer];
    
    if (self.haveChangedAnswer == NO && dueUserAction == YES) {
        self.haveChangedAnswer = YES;
    }
}

- (void)answerCell:(ORKSurveyAnswerCell *)cell invalidInputAlertWithMessage:(NSString *)input {
    [self _showValidityAlertWithMessage:input];
}

static NSString * const _ORKAnswerRestoreKey = @"answer";
static NSString * const _ORKHaveChangedAnswerRestoreKey = @"haveChangedAnswer";



- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:_answer forKey:_ORKAnswerRestoreKey];
    [coder encodeBool:_haveChangedAnswer forKey:_ORKHaveChangedAnswerRestoreKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.answer = [coder decodeObjectOfClasses:[NSSet setWithObjects:[NSNumber class],[NSString class],[NSDateComponents class],[NSArray class], nil] forKey:_ORKAnswerRestoreKey];
    self.haveChangedAnswer = [coder decodeBoolForKey:_ORKHaveChangedAnswerRestoreKey];
    
    [self _answerDidChange];
}

@end
