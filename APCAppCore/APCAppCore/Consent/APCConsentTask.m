// 
//  APCConsentTask.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
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
 
#import "APCConsentTask.h"
#import "APCLog.h"
#import "APCConsentQuestion.h"
#import "APCConsentBooleanQuestion.h"
#import "APCConsentInstructionQuestion.h"
#import "APCConsentTextChoiceQuestion.h"
#import "APCConsentRedirector.h"
#import "APCAppDelegate.h"
#import <BridgeSDK/BridgeSDK.h>


static NSString*    kDocumentHtmlTag                    = @"htmlDocument";
static NSString*    kInvestigatorShortDescriptionTag    = @"investigatorShortDescription";
static NSString*    kInvestigatorLongDescriptionTag     = @"investigatorLongDescription";
static NSString*    kHtmlContentTag                     = @"htmlContent";
static NSString*    kIdentifierTag                      = @"identifier";
static NSString*    kPromptTag                          = @"prompt";
static NSString*    kTextTag                            = @"text";
static NSString*    kSuccessTitleTag                    = @"successTitle";
static NSString*    kSuccessMessageTag                  = @"successMessage";
static NSString*    kFailedTitleTag                     = @"failureTitle";
static NSString*    kFailedMessageTag                   = @"failureMessage";
static NSString*    kDocumentPropertiesTag              = @"documentProperties";
static NSString*    kQuizTag                            = @"quiz";
static NSString*    kSectionTag                         = @"sections";
static NSString*    kQuestionsTag                       = @"questions";
static NSString*    kQuestionTypeTag                    = @"type";
static NSString*    kBooleanTypeTag                     = @"boolean";
static NSString*    kSingleChoiceTextTag                = @"singleChoiceText";
static NSString*    kInstructionTypeTag                 = @"instruction";
static NSString*    kExpectedAnswerTag                  = @"expectedAnswer";
static NSString*    kTrueTag                            = @"true";
static NSString*    kFalseTag                           = @"false";
static NSString*    kTextChoicesTag                     = @"textChoices";
static NSString*    kAllowedFailuresCountTag            = @"allowedFailures";
static NSString*    kSharingTag                         = @"sharing";

static NSString*    kStepIdentifierSuffixStart          = @"+X";



@interface APCConsentTask ()

@property (nonatomic, copy)   NSString*         identifier;
@property (nonatomic, strong) NSMutableArray*   steps;

@property (nonatomic, strong) NSMutableArray*   consentSteps;
@property (nonatomic, assign) BOOL              passedQuiz;

@property (nonatomic, copy)   NSString*         documentHtmlContent;

//  Quiz properties
@property (nonatomic, copy)   NSArray*          questions;
@property (nonatomic, strong) NSString*         currentQuestionStepSuffix;
@property (nonatomic, assign) NSUInteger        currentQuestionStepSuffixValue;

@property (nonatomic, copy)   NSString*         successTitle;
@property (nonatomic, copy)   NSString*         failureTitle;
@property (nonatomic, copy)   NSString*         successMessage;
@property (nonatomic, copy)   NSString*         failureMessage;
@property (nonatomic, assign) NSUInteger        maxAllowedFailure;

@property (nonatomic, assign) NSInteger         indexOfFirstCustomStep;
@property (nonatomic, assign) NSInteger         indexOfFirstQuizStep;

//  Consent
@property (nonatomic, strong) NSArray*          documentSections;

//  Sharing
@property (nonatomic, copy)   NSString*         investigatorShortDescription;
@property (nonatomic, copy)   NSString*         investigatorLongDescription;
@property (nonatomic, copy)   NSString*         sharingHtmlLearnMoreContent;

@property (nonatomic, strong, readwrite) ORKConsentSharingStep *sharingStep;
@property (nonatomic, strong) ORKVisualConsentStep *visualStep;

@property (nonatomic, strong) ORKStep*   lastQuestionStep;
@property (nonatomic, strong) ORKStep*   resultQuestionStep;
@property (nonatomic, strong) ORKStep*   afterResultQuestionStep;

@end


@implementation APCConsentTask


- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName
{
    NSString*   reason      = @"By agreeing you confirm that you read the information and that you "
                              @"wish to take part in this research study.";
    NSArray*    consentSteps = [self commonInitWithPropertiesFileName:fileName customSteps:nil reasonForConsent:reason];
    
    _consentSteps = [consentSteps mutableCopy];
    _identifier = identifier;
    _steps      = [consentSteps mutableCopy];
    _failedMessageTag = kFailedMessageTag;
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName reasonForConsent:(NSString*)reason
{
    NSArray*    consentSteps = [self commonInitWithPropertiesFileName:fileName customSteps:nil reasonForConsent:reason];
    
    _consentSteps = [consentSteps mutableCopy];
    _identifier = identifier;
    _steps      = [consentSteps mutableCopy];
    _failedMessageTag = kFailedMessageTag;
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps
{
    NSString*   reason      = @"By agreeing you confirm that you read the information and that you "
                              @"wish to take part in this research study.";
    NSArray*    consentSteps = [self commonInitWithPropertiesFileName:fileName customSteps:customSteps reasonForConsent:reason];

    _consentSteps = [consentSteps mutableCopy];
    _identifier = identifier;
    _steps      = [consentSteps mutableCopy];
    
    return self;
}

- (NSArray*)commonInitWithPropertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps reasonForConsent:(NSString*)reason
{
    _passedQuiz             = YES;
    _indexOfFirstCustomStep = NSNotFound;
    _indexOfFirstQuizStep   = NSNotFound;
    
    _currentQuestionStepSuffix      = @"";
    _currentQuestionStepSuffixValue = 0;
    
    [self loadFromJson:fileName];
    
    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    ORKConsentDocument*     document  = [[ORKConsentDocument alloc] init];
    
    document.title                = NSLocalizedString(@"Consent", nil);
    document.signaturePageTitle   = NSLocalizedString(@"Consent", nil);
    document.signaturePageContent = NSLocalizedString(@"By agreeing you confirm that you read the consent and that you wish to take part in this research study.", nil);
    document.sections             = self.documentSections;
    document.htmlReviewContent    = self.documentHtmlContent;
    
    [document addSignature:signature];
    
    _consentDocument = document;
    
    
    _visualStep  = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual"
                                                           document:_consentDocument];
    _sharingStep = [[ORKConsentSharingStep alloc] initWithIdentifier:kSharingTag
                                        investigatorShortDescription:self.investigatorShortDescription
                                         investigatorLongDescription:self.investigatorLongDescription
                                       localizedLearnMoreHTMLContent:self.sharingHtmlLearnMoreContent];
    
    APCAppDelegate* delegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
    BOOL disableSignatureInConsent = delegate.disableSignatureInConsent;
    
    if (disableSignatureInConsent) {
        signature.requiresSignatureImage = NO;
    }
    
    ORKConsentReviewStep*   reviewStep  = [[ORKConsentReviewStep alloc] initWithIdentifier:@"reviewStep"
                                                                                 signature:signature
                                                                                inDocument:_consentDocument];
    
    reviewStep.reasonForConsent = reason;
    
    NSMutableArray* consentSteps = [[NSMutableArray alloc] init];
    [consentSteps addObject:_visualStep];
    [consentSteps addObject:_sharingStep];
    
    _indexOfFirstCustomStep = consentSteps.count;
    [consentSteps addObjectsFromArray:customSteps];
    
    _indexOfFirstQuizStep = consentSteps.count;

    for (APCConsentQuestion* question in self.questions)
    {
        [consentSteps addObject:question.instantiateRkQuestion];
    }
    [consentSteps addObject:reviewStep];
    
    return consentSteps;
}

- (ORKStep*)failureStep
{
    ORKInstructionStep* step = nil;
    
    if (self.successMessage != nil)
    {
        step = [[ORKInstructionStep alloc] initWithIdentifier:kFailedMessageTag];
        step.title = self.failureTitle;
        step.text  = self.failureMessage;
        step.image = [UIImage imageNamed:@"consent_quiz_retry"];
    }

    return step;
}

- (ORKStep*)successStep
{
    ORKInstructionStep* step = nil;
    
    if (self.successMessage != nil)
    {
        step = [[ORKInstructionStep alloc] initWithIdentifier:kSuccessMessageTag];
        step.title = self.successTitle;
        step.text  = self.successMessage;
        step.image = [UIImage imageNamed:@"Completion-Check"];
    }
    
    return step;
}


#pragma mark ORKTask methods

- (ORKStep*)stepAfterStep:(ORKStep*)step withResult:(ORKTaskResult*)result
{
    BOOL(^compareStep)(ORKStep*, NSUInteger, BOOL*) = ^(ORKStep* s, NSUInteger  __unused ndx, BOOL* __unused stop)
    {
        return [s.identifier isEqualToString: step.identifier];
    };
    
    BOOL(^compareQuestion)(APCConsentQuestion*, NSUInteger, BOOL*) = ^(APCConsentQuestion* q, NSUInteger __unused ndx, BOOL* __unused stop)
    {
        return [q.extendedIdentifier isEqualToString: step.identifier];
    };
    
    APCConsentQuestion*(^findQuestion)(NSString*) = ^(NSString* identifier)
    {
        APCConsentQuestion* target = nil;
        
        for (APCConsentQuestion* q in self.questions)
        {
            if ([q.extendedIdentifier isEqualToString:identifier])
            {
                target = q;
                break;
            }
        }
        return target;
    };
    
    BOOL(^proctor)() = ^()
    {
        NSUInteger  failureCount = 0;
        
        for (ORKStepResult* stepResult in result.results)
        {
            APCConsentQuestion*     q = findQuestion(stepResult.identifier);
            if (q != nil)
            {
                if ([q evaluate:stepResult] == NO)
                {
                    ++failureCount;
                }
            }
        }
        
        BOOL    didPass = failureCount <= self.maxAllowedFailure;
        
        return didPass;
    };
    
    ORKStep*(^findNextStep)() = ^()
    {
        ORKStep*    nextStep  = nil;
        NSUInteger  stepIndex = [self.steps indexOfObjectPassingTest:compareStep];
        
        if (stepIndex != NSNotFound && stepIndex < self.steps.count - 1)  //  Ensures we find a step and don't run off the end
        {
            NSUInteger  questionIndex = [self.questions indexOfObjectPassingTest:compareQuestion];
            
            if (questionIndex == NSNotFound)                    //  Are we at a question?
            {
                nextStep = self.steps[stepIndex + 1];           //  Pick the next step
            }
            else
            {
                if (questionIndex == self.questions.count - 1)  //  Is `step` the last question?
                {
                    if (proctor(result))
                    {
                        nextStep = [self successStep];
                    }
                    else
                    {
                        nextStep = [self failureStep];
                    }
                    self.lastQuestionStep = step;
                    self.resultQuestionStep = nextStep;
                }
                else
                {
                    nextStep = self.steps[stepIndex + 1];
                }
            }
        }
        return nextStep;
    };
    
    ORKStep*    nextStep = nil;
    
    if (step == nil)    //  First step?
    {
        nextStep = self.steps.firstObject;
        self.passedQuiz = YES;
    }
    else if ([step.identifier isEqualToString:kSharingTag])
    {
        nextStep = findNextStep();
    }
    else if ([step.identifier isEqualToString:kSuccessMessageTag])
    {
        nextStep = self.steps.lastObject;
    }
    else if ([step.identifier isEqualToString:self.failedMessageTag])
    {
        if (self.redirector != nil && [self.redirector conformsToProtocol:@protocol(APCConsentRedirector)])
        {
            APCConsentRedirection   redirection = [self.redirector redirect];
            
            if (redirection == APCConsentBackToConsentBeginning)
            {
                nextStep = self.steps.firstObject;
            }
            else if (redirection == APCConsentBackToCustomStepBeginning)
            {
                nextStep = self.steps[self.indexOfFirstCustomStep];
            }
            else if (redirection == APCConsentBackToQuizBeginning)
            {
                nextStep = self.steps[self.indexOfFirstQuizStep];
            }
            else if (redirection == APCConsentRedirectionNone)
            {
                nextStep = self.steps.lastObject;
            }
        }
        else
        {
            self.currentQuestionStepSuffixValue = self.currentQuestionStepSuffixValue + 1;
            self.currentQuestionStepSuffix = [NSString stringWithFormat:@"%@%04lu", kStepIdentifierSuffixStart, self.currentQuestionStepSuffixValue];
            
            NSMutableArray  *replacer = [NSMutableArray array];
            
            for (APCConsentQuestion* question in self.questions)
            {
                question.suffix = self.currentQuestionStepSuffix;
                ORKStep  *stepster = question.instantiateRkQuestion;
                [replacer addObject:stepster];
            }
            NSRange  replacementRange = NSMakeRange(self.indexOfFirstQuizStep, [self.questions count]);
            [self.steps        replaceObjectsInRange:replacementRange withObjectsFromArray:replacer];
            [self.consentSteps replaceObjectsInRange:replacementRange withObjectsFromArray:replacer];
            
            nextStep = self.steps.firstObject;
        }
    }
    else
    {
        nextStep = findNextStep();
    }
    
    if (step == self.resultQuestionStep) {
        self.afterResultQuestionStep = nextStep;
    }
    
    return nextStep;
}


- (ORKStep*)stepBeforeStep:(ORKStep*)step withResult:(ORKTaskResult*) __unused result
{
    ORKStep*    previousStep = nil;
    
    if (step == nil)
    {
        previousStep = self.consentSteps.lastObject;
    }
    else
    {
        NSUInteger  ndx = [self.consentSteps indexOfObject:step];
        if (step == self.resultQuestionStep)
        {
            previousStep = self.lastQuestionStep;
        }
        else if (step == self.afterResultQuestionStep)
        {
            previousStep = self.resultQuestionStep;
        }
        else if (ndx == NSNotFound)
        {
            previousStep = self.visualStep;
        }
        else if (ndx > 0)
        {
            previousStep = self.consentSteps[ndx - 1];
        }
    }
    
    return previousStep;
}

- (ORKStep*)stepWithIdentifier:(NSString*) __unused identifier
{
    return nil;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep*) __unused step withResult:(ORKTaskResult*) __unused result
{
    return ORKTaskProgressMake(0, 0);
}

#pragma mark Loading consent from JSON

- (void)loadFromJson:(NSString*)fileName
{
    NSString*       filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSAssert(filePath != nil, @"Unable to location file with Consent Section in main bundle");
    
    NSData*         fileContent = [NSData dataWithContentsOfFile:filePath];
    NSAssert(fileContent != nil, @"Unable to create NSData with file content (Consent data)");
    
    NSError*        error             = nil;
    NSDictionary*   consentParameters = [NSJSONSerialization JSONObjectWithData:fileContent options:NSJSONReadingMutableContainers error:&error];
    NSAssert(consentParameters != nil, @"badly formed Consent parameters (not JSON) - error", error);

    NSDictionary*   documentParameters = [consentParameters objectForKey:kDocumentPropertiesTag];
    if (documentParameters != nil)
    {
        [self loadDocumentProperties:documentParameters];
    }
    
    NSDictionary*   quizParameters = [consentParameters objectForKey:kQuizTag];
    if (quizParameters != nil)
    {
        [self loadQuiz:quizParameters];
    }
    
    NSArray*    sectionParameters = [consentParameters objectForKey:kSectionTag];
    if (sectionParameters != nil)
    {
        [self loadSections:sectionParameters];
    }
}

- (void)loadDocumentProperties:(NSDictionary*)properties
{
    NSString*   documentHtmlContent = [properties objectForKey:kDocumentHtmlTag];
    NSAssert(documentHtmlContent == nil || documentHtmlContent != nil && [documentHtmlContent isKindOfClass:[NSString class]], @"Improper Document HTML Content type");
    
    if (documentHtmlContent != nil)
    {
        NSString*   path    = [[NSBundle mainBundle] pathForResource:documentHtmlContent ofType:@"html" inDirectory:@"HTMLContent"];
        NSAssert(path != nil, @"Unable to locate HTML file: %@", documentHtmlContent);
        
        if (path != nil)
        {
            NSError*    error = nil;
            self.documentHtmlContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            
            if (self.documentHtmlContent == nil)
            {
                APCLogError2(error);
            }
        }
    }

    self.investigatorShortDescription = [properties objectForKey:kInvestigatorShortDescriptionTag];
    NSAssert(self.investigatorShortDescription != nil && [self.investigatorShortDescription isKindOfClass:[NSString class]], @"Improper type for Investigator Short Description");
    
    self.investigatorLongDescription = [properties objectForKey:kInvestigatorLongDescriptionTag];
    NSAssert(self.investigatorLongDescription != nil && [self.investigatorLongDescription isKindOfClass:[NSString class]], @"Improper type for Investigator Long Description");

    NSString*   htmlContent = [properties objectForKey:kHtmlContentTag];
    if (htmlContent != nil)
    {
        NSString*   path    = [[NSBundle mainBundle] pathForResource:htmlContent ofType:@"html" inDirectory:@"HTMLContent"];
        NSAssert(path != nil, @"Unable to locate HTML file: %@", htmlContent);
        
        NSError*    error   = nil;
        NSString*   content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        
        NSAssert(content != nil, @"Unable to load content of file \"%@\": %@", path, error);
        
        self.sharingHtmlLearnMoreContent = content;
    }
}

#pragma mark Loading Quiz JSON

- (void)loadQuiz:(NSDictionary*)properties
{
    //  Failure and success messages are optioinal, questions, however are not.
    NSString*   failureTitle   = [properties objectForKey:kFailedTitleTag];
    NSString*   failureMessage = [properties objectForKey:kFailedMessageTag];
    NSString*   successTitle   = [properties objectForKey:kSuccessTitleTag];
    NSString*   successMessage = [properties objectForKey:kSuccessMessageTag];
    NSString*   allowedFailure = [properties objectForKey:kAllowedFailuresCountTag];
    NSArray*    questions      = [properties objectForKey:kQuestionsTag];
    NSAssert(questions != nil, @"No questions defined for Consent Quiz");
    
    self.successTitle       = successTitle;
    self.failureTitle       = failureTitle;
    self.failureMessage     = failureMessage;
    self.successMessage     = successMessage;
    self.maxAllowedFailure  = allowedFailure.integerValue;
    
    if (questions != nil)
    {
        NSMutableArray* parsedQuestions = [NSMutableArray arrayWithCapacity:questions.count];
        
        for (NSDictionary* questionProperties in questions)
        {
            APCConsentQuestion* question = [self loadQuestion:questionProperties];
            [parsedQuestions addObject:question];
        }
        self.questions = parsedQuestions;
    }
}

#pragma mark Loading Quiz Questions

- (APCConsentQuestion*)loadQuestion:(NSDictionary*)properties
{
    NSString*   type = [properties objectForKey:kQuestionTypeTag];
    NSAssert(type != nil, @"No question type defined for Question element");
    
    APCConsentQuestion* question = nil;
    
    if ([type isEqualToString:kBooleanTypeTag])
    {
        question = [self loadBooleanQuestion:properties];
    }
    else if ([type isEqualToString:kInstructionTypeTag])
    {
        question = [self loadInstructionQuestion:properties];
    }
    else if ([type isEqualToString:kSingleChoiceTextTag])
    {
        question = [self loadTextChoiceQuestion:properties];
    }
 
    return question;
}

- (APCConsentBooleanQuestion*)loadBooleanQuestion:(NSDictionary*)properties
{
    NSString*   identifier     = [properties objectForKey:kIdentifierTag];
    NSAssert(identifier != nil, @"Missing identifier for boolean question");
    
    NSString*   prompt         = [properties objectForKey:kPromptTag];
    NSAssert(prompt != nil, @"Missing prompt for boolean question");
    
    NSString*   expectedString = [properties objectForKey:kExpectedAnswerTag];
    NSAssert(expectedString, @"Missing Expected Answer for boolean question");
    BOOL        expected       = false;
    
    if ([expectedString isEqualToString:kTrueTag])
    {
        expected = YES;
    }
    else if ([expectedString isEqualToString:kFalseTag])
    {
        expected = NO;
    }
    else
    {
        //  error
        NSAssert(true, @"Unknown Expected Answer for boolean question:", expectedString);
    }
    APCConsentBooleanQuestion*  question = [[APCConsentBooleanQuestion alloc] initWithIdentifier:identifier
                                                                                          prompt:prompt
                                                                                          suffix:self.currentQuestionStepSuffix
                                                                                  expectedAnswer:expected];
    
    return question;
}


- (APCConsentInstructionQuestion*)loadInstructionQuestion:(NSDictionary*)properties
{
    NSString*   identifier     = [properties objectForKey:kIdentifierTag];
    NSAssert(identifier != nil, @"Missing identifier for Instruction Question");
    
    NSString*   prompt         = [properties objectForKey:kPromptTag];
    NSString*   text           = [properties objectForKey:kTextTag];
    
    APCConsentInstructionQuestion*  question = [[APCConsentInstructionQuestion alloc] initWithIdentifier:identifier
                                                                                                  prompt:prompt
                                                                                                suffix:self.currentQuestionStepSuffix
                                                                                                    text:text];
    
    return question;
}

- (APCConsentTextChoiceQuestion*)loadTextChoiceQuestion:(NSDictionary*)properties
{
    NSString*   identifier      = [properties objectForKey:kIdentifierTag];
    NSAssert(identifier != nil, @"Missing identifier for Instruction Question");
    
    NSString*   prompt              = [properties objectForKey:kPromptTag];
    NSString*   expectedString      = [properties objectForKey:kExpectedAnswerTag];
    NSArray*    choicesProperties   = [properties objectForKey:kTextChoicesTag];
    NSArray*    choices             = [self loadChoices:choicesProperties];

    
    APCConsentTextChoiceQuestion*   question = [[APCConsentTextChoiceQuestion alloc] initWithIdentifier:identifier
                                                                                                 prompt:prompt
                                                                                                suffix:self.currentQuestionStepSuffix
                                                                                                answers:choices
                                                                                         expectedAnswer:expectedString.integerValue];
    return question;
}

#pragma mark Loading Choices

- (NSArray*)loadChoices:(NSArray*)properties
{
    for (NSString* choice in properties)
    {
        NSAssert([choice isKindOfClass:[NSString class]], @"Unexpected type for text choice");
    }
    
    return properties;
}

#pragma mark Loading Sections

- (void)loadSections:(NSArray*)properties
{
    ORKConsentSectionType(^toSectionType)(NSString*) = ^(NSString* sectionTypeName)
    {
        ORKConsentSectionType   sectionType = ORKConsentSectionTypeCustom;
        
        if ([sectionTypeName isEqualToString:@"overview"])
        {
            sectionType = ORKConsentSectionTypeOverview;
        }
        else if ([sectionTypeName isEqualToString:@"privacy"])
        {
            sectionType = ORKConsentSectionTypePrivacy;
        }
        else if ([sectionTypeName isEqualToString:@"dataGathering"])
        {
            sectionType = ORKConsentSectionTypeDataGathering;
        }
        else if ([sectionTypeName isEqualToString:@"dataUse"])
        {
            sectionType = ORKConsentSectionTypeDataUse;
        }
        else if ([sectionTypeName isEqualToString:@"timeCommitment"])
        {
            sectionType = ORKConsentSectionTypeTimeCommitment;
        }
        else if ([sectionTypeName isEqualToString:@"studySurvey"])
        {
            sectionType = ORKConsentSectionTypeStudySurvey;
        }
        else if ([sectionTypeName isEqualToString:@"studyTasks"])
        {
            sectionType = ORKConsentSectionTypeStudyTasks;
        }
        else if ([sectionTypeName isEqualToString:@"withdrawing"])
        {
            sectionType = ORKConsentSectionTypeWithdrawing;
        }
        else if ([sectionTypeName isEqualToString:@"custom"])
        {
            sectionType = ORKConsentSectionTypeCustom;
        }
        else if ([sectionTypeName isEqualToString:@"onlyInDocument"])
        {
            sectionType = ORKConsentSectionTypeOnlyInDocument;
        }
        
        return sectionType;
    };
    static NSString*   kSectionType            = @"sectionType";
    static NSString*   kSectionTitle           = @"sectionTitle";
    static NSString*   kSectionFormalTitle     = @"sectionFormalTitle";
    static NSString*   kSectionSummary         = @"sectionSummary";
    static NSString*   kSectionContent         = @"sectionContent";
    static NSString*   kSectionHtmlContent     = @"sectionHtmlContent";
    static NSString*   kSectionImage           = @"sectionImage";
    static NSString*   kSectionAnimationUrl    = @"sectionAnimationUrl";
    
    NSMutableArray* consentSections = [NSMutableArray arrayWithCapacity:properties.count];
    
    for (NSDictionary* section in properties)
    {
        //  Custom typesdo not have predefiend title, summary, content, or animation
        NSAssert([section isKindOfClass:[NSDictionary class]], @"Improper section type");
        
        NSString*   typeName     = [section objectForKey:kSectionType];
        NSAssert(typeName != nil && [typeName isKindOfClass:[NSString class]],    @"Missing Section Type or improper type");
        
        ORKConsentSectionType   sectionType = toSectionType(typeName);
        
        NSString*   title        = [section objectForKey:kSectionTitle];
        NSString*   formalTitle  = [section objectForKey:kSectionFormalTitle];
        NSString*   summary      = [section objectForKey:kSectionSummary];
        NSString*   content      = [section objectForKey:kSectionContent];
        NSString*   htmlContent  = [section objectForKey:kSectionHtmlContent];
        NSString*   image        = [section objectForKey:kSectionImage];
        NSString*   animationUrl = [section objectForKey:kSectionAnimationUrl];
        
        NSAssert(title        == nil || title         != nil && [title isKindOfClass:[NSString class]],        @"Missing Section Title or improper type");
        NSAssert(formalTitle  == nil || formalTitle   != nil && [formalTitle isKindOfClass:[NSString class]],  @"Missing Section Formal title or improper type");
        NSAssert(summary      == nil || summary       != nil && [summary isKindOfClass:[NSString class]],      @"Missing Section Summary or improper type");
        NSAssert(content      == nil || content       != nil && [content isKindOfClass:[NSString class]],      @"Missing Section Content or improper type");
        NSAssert(htmlContent  == nil || htmlContent   != nil && [htmlContent isKindOfClass:[NSString class]],  @"Missing Section HTML Content or improper type");
        NSAssert(image        == nil || image         != nil && [image isKindOfClass:[NSString class]],        @"Missing Section Image or improper typte");
        NSAssert(animationUrl == nil || animationUrl  != nil && [animationUrl isKindOfClass:[NSString class]], @"Missing Animation URL or improper type");
        
        
        ORKConsentSection*  section = [[ORKConsentSection alloc] initWithType:sectionType];
        
        if (title != nil)
        {
            section.title = title;
        }
        
        if (formalTitle != nil)
        {
            section.formalTitle = formalTitle;
        }
        
        if (summary != nil)
        {
            section.summary = summary;
        }
        
        if (content != nil)
        {
            section.content = content;
        }
        
        if (htmlContent != nil)
        {
            NSString*   path    = [[NSBundle mainBundle] pathForResource:htmlContent ofType:@"html" inDirectory:@"HTMLContent"];
            NSAssert(path != nil, @"Unable to locate HTML file: %@", htmlContent);
            
            NSError*    error   = nil;
            NSString*   content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
            
            NSAssert(content != nil, @"Unable to load content of file \"%@\": %@", path, error);
            
            section.htmlContent = content;
        }
        
        if (image != nil)
        {
            section.customImage = [UIImage imageNamed:image];
            NSAssert(section.customImage != nil, @"Unable to load image: %@", image);
        }
        
        if (animationUrl != nil)
        {
            NSString * nameWithScaleFactor = animationUrl;
            if ([[UIScreen mainScreen] scale] >= 3)
            {
                nameWithScaleFactor = [nameWithScaleFactor stringByAppendingString:@"@3x"];
            }
            else
            {
                nameWithScaleFactor = [nameWithScaleFactor stringByAppendingString:@"@2x"];
            }
            NSURL*      url   = [[NSBundle mainBundle] URLForResource:nameWithScaleFactor withExtension:@"m4v"];
            NSError*    error = nil;
            
            NSAssert([url checkResourceIsReachableAndReturnError:&error], @"Animation file--%@--not reachable: %@", animationUrl, error);
            section.customAnimationURL = url;
        }
        
        [consentSections addObject:section];
    }

    self.documentSections = consentSections;
}


@end
