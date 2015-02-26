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


static NSString*    kIdentifierTag     = @"identifier";
static NSString*    kPromptTag         = @"prompt";
static NSString*    kTextTag           = @"text";
static NSString*    kSuccessMessageTag = @"successMessage";
static NSString*    kFailedMessageTag  = @"failedMessage";


@interface APCConsentTask ()

//@property (nonatomic, copy)   NSString*         identifier;
@property (nonatomic, strong) NSMutableArray*   consentSteps;
@property (nonatomic, strong) APCStack*         path;
@property (nonatomic, assign) BOOL              passedQuiz;

@property (nonatomic, copy)   NSString*         documentHtmlContent;

//  Quiz properties
@property (nonatomic, copy)   NSArray*          questions;
@property (nonatomic, copy)   NSString*         successMessage;
@property (nonatomic, copy)   NSString*         failureMessage;

//  Consent
@property (nonatomic, strong) NSArray*          documentSections;

@end


@implementation APCConsentTask


- (instancetype)initWithIdentifier:(NSString*)identifier propertiesFileName:(NSString*)fileName
{
    _passedQuiz = YES;
    
    [self loadFromJson:fileName];

    ORKConsentSignature*    signature = [ORKConsentSignature signatureForPersonWithTitle:@"Participant"
                                                                        dateFormatString:nil
                                                                              identifier:@"participant"];
    ORKConsentDocument*     document  = [[ORKConsentDocument alloc] init];
    
    document.title                = @"Consent";
    document.signaturePageTitle   = @"Consent";
    document.signaturePageContent = @"By agreeing you confirm that you read the information and that you "
                                    @"wish to take part in this research study.";
    document.sections             = self.documentSections;
    
    [document addSignature:signature];
    
    
    ORKVisualConsentStep*   visualStep = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual" document:document];
    ORKConsentReviewStep*   reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"reviewStep" signature:signature inDocument:document];
    
    reviewStep.reasonForConsent = @"By agreeing you confirm that you read the information and that you "
                                  @"wish to take part in this research study.";

    NSMutableArray* consentSteps = [[NSMutableArray alloc] init];
    [consentSteps addObject:visualStep];
    
    for (APCConsentQuestion* q in self.questions)
    {
        [consentSteps addObject:q.instantiateRkQuestion];
    }
    
    [consentSteps addObject:reviewStep];
    
    self = [super initWithIdentifier:identifier steps:consentSteps];
    
    return self;
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
    ORKStep*    step = nil;
    
    if (self.successMessage != nil)
    {
        step = [[ORKInstructionStep alloc] initWithIdentifier:kFailedMessageTag];
        step.title = NSLocalizedString(@"Failed", nil);
        step.text  = self.failureMessage;
    }

    return step;
}

- (ORKStep*)successStep
{
    ORKStep*    step = nil;
    
    if (self.successMessage != nil)
    {
        step = [[ORKInstructionStep alloc] initWithIdentifier:kSuccessMessageTag];
        step.title = NSLocalizedString(@"Passed", nil);
        step.text  = self.successMessage;
    }
    
    return step;
}


#pragma mark ORKTask methods

- (ORKStep*)stepAfterStep:(ORKStep*)step withResult:(ORKTaskResult*)result
{
    BOOL(^compareStep)(ORKStep*, NSUInteger, BOOL*) = ^(ORKStep* s, NSUInteger ndx, BOOL* stop)
    {
        return [s.identifier isEqualToString:step.identifier];
    };
    BOOL(^compareQuestion)(APCConsentQuestion*, NSUInteger, BOOL*) = ^(APCConsentQuestion* q, NSUInteger ndx, BOOL* stop)
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
        BOOL    didPass = YES;
        
        for (ORKStepResult* stepResult in result.results)
        {
            APCConsentQuestion*     q = findQuestion(stepResult.identifier);
            if (q != nil)
            {
                didPass &= [q evaluate:stepResult];
            }
        }
        
        return didPass;
    };
    ORKStep*    nextStep = nil;
    
    if (step == nil)    //  First step?
    {
        nextStep = self.steps.firstObject;
        self.passedQuiz = YES;
    }
    else if ([step.identifier isEqualToString:kSuccessMessageTag])
    {
        nextStep = self.steps.lastObject;
    }
    else if ([step.identifier isEqualToString:kFailedMessageTag])
    {
        //  do nothing
    }
    else
    {
        NSUInteger  stepIndex = [self.steps indexOfObjectPassingTest:compareStep];
        
        if (stepIndex != NSNotFound && stepIndex < self.steps.count - 1)  //  Ensures we find a step and don't run off the end
        {
            NSUInteger  questionIndex = [self.questions indexOfObjectPassingTest:compareQuestion];
            
            if (questionIndex == NSNotFound)    //  Are we at a question?
            {
                nextStep = self.steps[stepIndex + 1];   //  Pick the next step
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
    }
    
    
    if (nextStep != nil)
    {
        [self.path push:nextStep];                          //  Record our path
    }
    
    return nextStep;
}


- (ORKStep*)stepBeforeStep:(ORKStep*)step withResult:(ORKTaskResult*)result
{
    ORKStep*    previousStep = nil;
    
    if (self.path.count > 0)
    {
        previousStep = [self.path pop];
    }
    
    return previousStep;
}

- (ORKStep*)stepWithIdentifier:(NSString*)identifier
{
    return nil;
}

- (ORKTaskProgress)progressOfCurrentStep:(ORKStep*)step withResult:(ORKTaskResult*)result
{
    return ORKTaskProgressMake(0, 0);
}

#pragma mark Loading consent from JSON

- (void)loadFromJson:(NSString*)fileName
{
    static NSString*    kDocumentPropertiesTag = @"documentProperties";
    static NSString*    kQuizTag               = @"quiz";
    static NSString*    kSectionTag            = @"sections";
    
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
    //  "documentProperties" :
    //  {
    //      "htmlDocument" : "cardio_fullconsent"
    //  }
    
    static NSString*   kDocumentHtmlTag    = @"htmlDocument";
    
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
}

- (void)loadQuiz:(NSDictionary*)properties
{
    /*
         "quiz":
         {
             "questions":
             [
                 {
                    "identifier": "question1",
                     "prompt": "Continue",
                     "type": "boolean",
                     "expectedAnswer": "true"
                 }
             ].
             "failure": "",
             "success": ""
         }
     */
    //  type: boolean, others??
    static NSString*    kQuestionsTag      = @"questions";
    static NSString*    kFailureMessageTag = @"failure";
    static NSString*    kSuccessMessageTag = @"success";
    
    NSString*   failureMessage = [properties objectForKey:kFailureMessageTag];
    NSString*   sucessMessage  = [properties objectForKey:kSuccessMessageTag];
    NSArray*    questions      = [properties objectForKey:kQuestionsTag];
    
    self.failureMessage = failureMessage;
    self.successMessage = sucessMessage;
    
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
    /*
         {
             "identifier": "question1",
             "prompt": "Continue",
             "type": "boolean",
             "expectedAnswer": "true"
         }
     */
    static NSString*    kQuestionTypeTag    = @"type";
    static NSString*    kBooleanTypeTag     = @"boolean";
    static NSString*    kInstructionTypeTag = @"instruction";

    NSString*           type     = [properties objectForKey:kQuestionTypeTag];
    APCConsentQuestion* question = nil;
    
    if ([type isEqualToString:kBooleanTypeTag])
    {
        question = [self loadBooleanQuestion:properties];
    }
    else if ([type isEqualToString:kInstructionTypeTag])
    {
        question = [self loadInstructionQuestion:properties];
    }
 
    return question;
}

- (APCConsentBooleanQuestion*)loadBooleanQuestion:(NSDictionary*)properties
{
    static NSString*    kExpectedAnswerTag = @"expectedAnswer";
    static NSString*    kTrueTag           = @"true";
    static NSString*    kFalseTag          = @"false";
    
    NSString*   identifier     = [properties objectForKey:kIdentifierTag];
    NSString*   prompt         = [properties objectForKey:kPromptTag];
    NSString*   expectedString = [properties objectForKey:kExpectedAnswerTag];
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
    }
    APCConsentBooleanQuestion*  question = [[APCConsentBooleanQuestion alloc] initWithIdentifier:identifier
                                                                                          prompt:prompt
                                                                                  expectedAnswer:expected];
    
    return question;
}

- (APCConsentInstructionQuestion*)loadInstructionQuestion:(NSDictionary*)properties
{
    NSString*   identifier     = [properties objectForKey:kIdentifierTag];
    NSString*   prompt         = [properties objectForKey:kPromptTag];
    NSString*   text           = [properties objectForKey:kTextTag];
    
    APCConsentInstructionQuestion*  question = [[APCConsentInstructionQuestion alloc] initWithIdentifier:identifier
                                                                                                  prompt:prompt
                                                                                                    text:text];
    
    return question;
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
