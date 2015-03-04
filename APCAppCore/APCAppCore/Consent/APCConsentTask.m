//
//  APCConsentTask.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCConsentTask.h"
#import "APCStack.h"
#import "APCLog.h"
#import "APCConsentBooleanQuestion.h"
#import "APCConsentInstructionQuestion.h"
#import "APCConsentTextChoiceQuestion.h"
#import "APCConsentRedirector.h"
#import "APCAppDelegate.h"


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



@interface APCConsentTask ()

@property (nonatomic, strong) NSMutableArray*   consentSteps;
@property (nonatomic, strong) APCStack*         path;
@property (nonatomic, assign) BOOL              passedQuiz;

@property (nonatomic, copy)   NSString*         documentHtmlContent;

//  Quiz properties
@property (nonatomic, copy)   NSArray*          questions;
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

@end


@implementation APCConsentTask


- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName
{
    NSArray*    consentSteps = [self commonInitWithPropertiesFileName:fileName customSteps:nil];
    
    self = [super initWithIdentifier:identifier steps:consentSteps];
    if (self)
    {
        _failedMessageTag = kFailedMessageTag;
    }
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps
{
    NSArray*    consentSteps = [self commonInitWithPropertiesFileName:fileName customSteps:customSteps];
    
    self = [super initWithIdentifier:identifier steps:consentSteps];
    if (self)
    {
    
    }
    
    return self;
}

- (NSArray*)commonInitWithPropertiesFileName:(NSString*)fileName customSteps:(NSArray*)customSteps
{
    _passedQuiz             = YES;
    _indexOfFirstCustomStep = NSNotFound;
    _indexOfFirstQuizStep   = NSNotFound;
    
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
    
    
    ORKVisualConsentStep*   visualStep  = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual"
                                                                                  document:_consentDocument];
    ORKConsentSharingStep*  sharingStep = [[ORKConsentSharingStep alloc] initWithIdentifier:kSharingTag
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
    
    reviewStep.reasonForConsent = @"By agreeing you confirm that you read the information and that you "
                                  @"wish to take part in this research study.";
    
    NSMutableArray* consentSteps = [[NSMutableArray alloc] init];
    [consentSteps addObject:visualStep];
    [consentSteps addObject:sharingStep];
    
    _indexOfFirstCustomStep = consentSteps.count;
    [consentSteps addObjectsFromArray:customSteps];
    
    _indexOfFirstQuizStep = consentSteps.count;
    for (APCConsentQuestion* q in self.questions)
    {
        [consentSteps addObject:q.instantiateRkQuestion];
    }
    
    [consentSteps addObject:reviewStep];
    
    return consentSteps;
}


- (NSArray*)instantiateQuiz:(NSArray*)rawQuizArray
{
    NSMutableArray* rkQuestions = [NSMutableArray arrayWithCapacity:rawQuizArray.count];
    
    for (APCConsentQuestion* rawQuestion in rawQuizArray)
    {
        ORKStep*    step = [rawQuestion instantiateRkQuestion];
        
        [rkQuestions addObject:step];
    }
    
    return rkQuestions;
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
        return [s.identifier isEqualToString:step.identifier];
    };
    BOOL(^compareQuestion)(APCConsentQuestion*, NSUInteger, BOOL*) = ^(APCConsentQuestion* q, NSUInteger __unused ndx, BOOL* __unused stop)
    {
        return [q.identifier isEqualToString:step.identifier];
    };
    APCConsentQuestion*(^findQuestion)(NSString*) = ^(NSString* identifier)
    {
        APCConsentQuestion* target = nil;
        
        for (APCConsentQuestion* q in self.questions)
        {
            if ([q.identifier isEqualToString:identifier] == YES)
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
                    if (proctor(result) == YES)
                    {
                        nextStep = [self successStep];
                    }
                    else
                    {
                        nextStep = [self failureStep];
                    }
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
        // Check for the sharing options answer and set the answer in the data model
        ORKStepResult*  sharingStep = [result stepResultForStepIdentifier:kSharingTag];
        if (sharingStep != nil)
        {
            NSArray *resultsOfSharingStep = [sharingStep results];
            
            if ([resultsOfSharingStep firstObject])
            {
                NSNumber*   sharingAnswer = [[[resultsOfSharingStep firstObject] choiceAnswers] firstObject];
                
                if (sharingAnswer != nil)
                {
                    APCAppDelegate* delegate = (APCAppDelegate*) [UIApplication sharedApplication].delegate;
                    NSInteger       selected = -1;
                    
                    if ([sharingAnswer integerValue] == 0)
                    {
                        selected = SBBConsentShareScopeStudy;
                    }
                    else if ([sharingAnswer integerValue] == 1)
                    {
                        selected = SBBConsentShareScopeAll;
                    }
                    
                    delegate.dataSubstrate.currentUser.sharedOptionSelection = [NSNumber numberWithInteger:selected];
                }
            }
        }
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
            nextStep = self.steps.firstObject;
        }
    }
    else
    {
        nextStep = findNextStep();
    }
    
    
    if (nextStep != nil)
    {
        [self.path push:nextStep];                          //  Record our path
    }
    
    return nextStep;
}


- (ORKStep*)stepBeforeStep:(ORKStep*) __unused step withResult:(ORKTaskResult*) __unused result
{
    ORKStep*    previousStep = nil;
    
    if (self.path.count > 0)
    {
        previousStep = [self.path pop];
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
                                                                                                answers:choices
                                                                                         expectedAnswer:expectedString.integerValue];
    return question;
}

- (NSArray*)loadChoices:(NSArray*)properties
{
    for (NSString* choice in properties)
    {
        NSAssert([choice isKindOfClass:[NSString class]], @"Unexpected type for text choice");
    }
    
    return properties;
}


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
            
            NSAssert([url checkResourceIsReachableAndReturnError:&error] == YES, @"Animation file--%@--not reachable: %@", animationUrl, error);
            section.customAnimationURL = url;
        }
        
        [consentSections addObject:section];
    }

    self.documentSections = consentSections;
}


@end
