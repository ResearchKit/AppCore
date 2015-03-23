#Obtaining an Informed Consent Document
Research studies that involve human subjects typically require an ethics committee in the US, an institutional review board (IRB) to approve the study. For some studies, the IRB requires informed consent, which means that the researcher must ensure that each participant is fully informed about the nature of the study, and must get a signed consent from each participant. A study that is deemed to be of low risk may have this requirement waived, but even in such cases it is useful to offer the information to participants.

ResearchKit makes it easy to display the informed consent document and to get participant signatures. Note that ResearchKit does not include digital signature support. If the signature needs to be verifiable and irrevocable, you are responsible for producing a digital signature or for generating a PDF that can be used to attest to the identity of the participant and the time at which the form was signed.

To obtain an informed consent document, you start by creating a document model object (`ORKConsentDocument`) that represents the   consent document. Then you create an informed consent task that contains a visual consent step and a consent review step. The visual consent step presents content from the consent document, and the review step gets the participant’s signature. This procedure is described in the sections that follows.

##1. Create the Consent Document Model
The document model  object (`ORKConsentDocument`) represents the content of the consent document, so that it can be used by both the `ORKVisualConsentStep` and the `ORKConsentReviewStep`. The code below generates a document model that is suitable to use in an `ORKVisualConsentStep`, providing both the "learn more" content and the short summary text for each visual consent screen. The signature content at the top is preparing the document for use with an `ORKConsentReviewStep` in which a signature needs to be obtained. You present this task using the task view controller (`ORKTaskViewController`).

 	ORKConsentDocument *document = [ORKConsentDocument new];
  	 ORKConsentSection *section = [[ORKConsentSection alloc]
  	 initWithType:ORKConsentSectionTypeDataGathering];
   	section.summary = "Lorem ipsum ...";
  	 section.content = @"The content to show in learn more ...";
   	// Create additional section objects for later sections
   	document.sections = @[s, ...];
   	ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc]
   	 initWithIdentifier:kVisualConsent document:document];
	   // And then create and present a task including this step.

##2. Create the Visual Consent Step
The visual consent step breaks the consent document into a series of screens with animated images. The animation consists of H.264 videos provided by ResearchKit, along with the titles of the sections. You can also add custom sections with your own images and content to the visual consent step.
It is your responsibility to populate the visual consent step with the content of the consent document, because the `ORKVisualConsentStep` object doesn’t contain any default content. 

 	 	 // Add consent sections for each page of visual consent; for example,
   	ORKConsentSection *section1 = [[ORKConsentSection alloc] 
   	initWithType:ORKConsentSectionTypeDataGathering];
  	 document.sections = @[section1, ...];
   	// Add the document to a visual consent step and/or a review step:
   	ORKVisualConsentStep *visualConsent = [[ORKVisualConsentStep alloc]
   	 initWithIdentifier:kVisualConsentIdentifier document:document];
   	ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc]
   	 initWithIdentifier:kConsentReviewIdentifier signature:document.signatures[0] 
   	 inDocument:document];
   	// And then create and present a task including these two steps.
        

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_1.png" style="width: 100%;border: solid black 1px; ">Consent overview screen (ORKConsentSectionTypeOverview object)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_2.png" style="width: 100%;border: solid black 1px;">Data gathering (ORKConsentSectionTypeDataGathering object).</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_3.png" style="width: 100%;border: solid black 1px;">Privacy (ORKConsentSectionTypePrivacy object)</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_4.png" style="width: 100%;border: solid black 1px; ">Data use disclosure (ORKConsentSectionTypeDataUse object)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_5.png" style="width: 100%;border: solid black 1px;">Time commitment (ORKConsentSectionTypeTimeCommitment object)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_6.png" style="width: 100%;border: solid black 1px;">Type of study survey (ORKConsentSectionTypeStudySurvey object)</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_7.png" style="width: 100%;border: solid black 1px; ">Study tasks (ORKConsentSectionTypeStudyTasks object</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_8.png" style="width: 100%;border: solid black 1px;"> Consent withdrawal (ORKConsentSectionTypeWithdrawing object).</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_9.png" style="width: 100%;border: solid black 1px;"> Custom consent section (ORKConsentSectionTypeCustom object)</p>
<p style="clear: both;">

##3. Create the Review Step
In the consent review step (`ORKConsentReviewStep`), users enter their name, review the consent document, and write a signature on the screen. You can also provide the content for the consent review step as HTML.
By default the consent review, document is collated from the individual consent sections. This content can be overridden to include other specific HTML content using the `htmlContent` property of `ORKConsentDocument`.  The text the consent review document is customizable with the `reasonForConsent` property of `ORKConsentReviewStep`.
The name entry page is included in the `ORKConsentReviewStep` if the `signature` property contains a signature object on which `requiresName` is true.
The signature entry page is included in the `ORKConsentReviewStep` if the `signature` property contains a signature object on which `requiresSignature` is true.

A consent review step uses `UIWebView` object in its public iOS APIs in its implementation.

	ORKConsentDocument *consent = [[ORKConsentDocument alloc] init];
	consent.title = @"Demo Consent";
    consent.signaturePageTitle = @"Consent";
      
	ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:consentDocument.signatures[0] inDocument:consentDocument];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_10.png" style="width: 100%;border: solid black 1px; ">Consent review (ORKConsentReviewStep object)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_11.png" style="width: 100%;border: solid black 1px;"> Agreeing to the consent document (reasonForConsent property of ORKConsentReviewStep object).</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_12.png" style="width: 100%;border: solid black 1px;"> Consent review name entry (signature property in ORKConsentReviewStep)</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="VisualStep_Images/VisualStep_13.png" style="width: 100%;border: solid black 1px; ">Consent review signature (signature property in ORKConsentReviewStep)</p>
<p style="clear: both;">

##4. Create the Informed Consent Task
Once you create the step(s), create an `ORKOrderedTask` task and add your step(s) to the task. To present the task, attach your task to the task view controller.

The following example shows how to create a task with a visual consent step and a consent review step:

    ORKVisualConsentStep *step = [[ORKVisualConsentStep alloc] initWithIdentifier:@"visual_consent" document:consent];
    ORKConsentReviewStep *reviewStep = [[ORKConsentReviewStep alloc] initWithIdentifier:@"consent_review" signature:consent.signatures[0] inDocument:consent];
    reviewStep.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    reviewStep.reasonForConsent = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    ORKOrderedTask *task = [[ORKOrderedTask alloc] initWithIdentifier:ConsentTaskIdentifier steps:@[step,reviewStep]];

##5. Optionally, generate a PDF
You have the option to generate a PDF of the signed form and provide it to the user. For example, your app can upload it to a server, email it to the participant, or display it within the app. 

The PDF generator method is defined in the `ORKConsentDocument` class. 
This method attaches the signature collected from  `ORKConsentReviewStep` step to the `ORKConsentSignatureResult` object back to `ORKConsentDocument` using the `applyToDocument` method of `ORKConsentSignatureResult`.

The following example of generates a pdf from the resulting consent document.

	{
        ORKStep *lastStep = [[(ORKOrderedTask *)taskViewController.task steps] lastObject];
        ORKConsentSignatureResult *signatureResult = (ORKConsentSignatureResult *)[[[taskViewController result] stepResultForStepIdentifier:lastStep.identifier] firstResult];
        //assert(signatureResult);
        
        [signatureResult applyToDocument:_currentDocument];
        
        [_currentDocument makePDFWithCompletionHandler:^(NSData *pdfData, NSError *error) {
                        
            if (! error) {
                NSURL *documents = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
                NSURL *outputUrl = [documents URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", [taskViewController.taskRunUUID UUIDString]]];
                
                [pdfData writeToURL:outputUrl atomically:YES];
              }
            
        }];