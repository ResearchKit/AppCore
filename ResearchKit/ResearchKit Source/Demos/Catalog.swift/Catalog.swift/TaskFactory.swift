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

import Foundation
import ResearchKit

let visualConsentStepIdentifier = "visualConsent"
let consentSharingStepIdentifier = "consentSharing"
let consentReviewStepIdentifier = "consentReview"
let consentTaskIdentifier = "consentTask"

func buildConsentTask() -> ORKTask {
    
    let consentDocument = buildConsentDocument()
    
    let visualStep = ORKVisualConsentStep(identifier: visualConsentStepIdentifier, document: consentDocument)
    let sharingStep = ORKConsentSharingStep(identifier: consentSharingStepIdentifier, investigatorShortDescription: "Institution", investigatorLongDescription: "Institution and its partners", localizedLearnMoreHTMLContent: "Your sharing learn more content here.")
    let reviewStep = ORKConsentReviewStep(identifier: consentReviewStepIdentifier, signature: consentDocument.signatures[0] as ORKConsentSignature, inDocument: consentDocument)
    reviewStep.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    reviewStep.reasonForConsent = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    let task = ORKOrderedTask(identifier: consentTaskIdentifier, steps: [visualStep, sharingStep, reviewStep])
    
    return task
}

func buildConsentDocument() -> ORKConsentDocument {
    
    let consent: ORKConsentDocument  = ORKConsentDocument()
    
    consent.title = "Demo Consent"
    consent.signaturePageTitle = "Consent"
    consent.signaturePageContent = "I agree to participate in this research study."
    
    let participantSig = ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil, identifier: "participantSig")
    consent.addSignature(participantSig)
    
    let investigatorSig = ORKConsentSignature(forPersonWithTitle: "Investigator", dateFormatString: nil, identifier: "investigatorSig", givenName: "Jonny", familyName: "Appleseed", signatureImage: UIImage(named: "signature.png"), dateString: "3/10/15")
    consent.addSignature(investigatorSig)
    
    let scenes: [ORKConsentSectionType] = [
        .Overview,
        .DataGathering,
        .Privacy,
        .DataUse,
        .TimeCommitment,
        .StudySurvey,
        .StudyTasks,
        .Withdrawing]
    
    let sections = NSMutableArray()
    
    let summuaryStr = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    let htmlContentStr = "<ul><li>Lorem</li><li>ipsum</li><li>dolor</li></ul><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>" +
    "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo?</p>"
    
    let contentStr = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?"
    
    for scene in scenes {
        let section = ORKConsentSection(type: scene)
        section.summary = summuaryStr
        
        if scene == ORKConsentSectionType.Overview {
            section.htmlContent = htmlContentStr
        } else {
            section.content = contentStr
        }
        
        sections.addObject(section)
    }
    
    let section = ORKConsentSection(type: ORKConsentSectionType.OnlyInDocument)
    section.summary = "OnlyInDocument Scene Summary"
    section.title = "OnlyInDocument Scene"
    section.content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam adhuc, meo fortasse vitio, quid ego quaeram non perspicis. Plane idem, inquit, et maxima quidem, qua fieri nulla maior potest. Quonam, inquit, modo? An potest, inquit ille, quicquam esse suavius quam nihil dolere? Cave putes quicquam esse verius. Quonam, inquit, modo?"
    sections.addObject(section)
    
    consent.sections = sections
    
    return consent
}

let introStepIdentifier = "introStep"
let questionStepIdentifier = "questionStep"
let summaryStepIdentifier = "summaryStep"
let surveyTaskIdentifier = "surveyTask"
let demoDescription = "Your description goes here."

func buildSurveyTask() -> ORKTask {
    
    let introStep = ORKInstructionStep(identifier: introStepIdentifier)
    introStep.title = "Sample Survey"
    introStep.text = demoDescription
    
    let questionStep = ORKQuestionStep(identifier: questionStepIdentifier, title: "Would you like to subscribe to our newsletter?", answer: ORKBooleanAnswerFormat())
    
    let summaryStep = ORKInstructionStep(identifier: summaryStepIdentifier)
    summaryStep.title = "Thanks"
    summaryStep.text = "Thank you for participating in this sample survey."
    
    let task = ORKOrderedTask(identifier: surveyTaskIdentifier, steps: [introStep, questionStep, summaryStep])
    
    return task
}

let fitnessTaskIdentifier = "fitnessCheck"

func buildFitnessTask() -> ORKTask {
    
    let task = ORKOrderedTask.fitnessCheckTaskWithIdentifier(fitnessTaskIdentifier, intendedUseDescription: demoDescription, walkDuration: 20, restDuration: 20, options: .None)
    
    return task
}

let shortWalkTaskIdentifier = "shortWalk"

func buildShortWalkTask() -> ORKTask {
    
    let task = ORKOrderedTask.shortWalkTaskWithIdentifier(shortWalkTaskIdentifier, intendedUseDescription: demoDescription, numberOfStepsPerLeg: 20, restDuration: 20, options: .None)
    
    return task
}

let audioTaskIdentifier = "audio"
let demoSpeechInstrunction = "Your more specific voice instruction goes here. For example, say 'Aaaah'."

func buildAudioTask() -> ORKTask {
    
    let task = ORKOrderedTask.audioTaskWithIdentifier(audioTaskIdentifier, intendedUseDescription: demoDescription, speechInstruction: demoSpeechInstrunction, shortSpeechInstruction: demoSpeechInstrunction, duration: 20, recordingSettings: nil, options: .None)
    
    return task
}

let twoFingerTappingIntervalTaskIdentifier = "twoFingerTappingInterval"

func buildTwoFingerTappingIntervalTask() -> ORKTask {
    
    let task = ORKOrderedTask.twoFingerTappingIntervalTaskWithIdentifier(twoFingerTappingIntervalTaskIdentifier, intendedUseDescription: demoDescription, duration: 20, options: .None)
    
    return task
}

let spatialSpanMemoryTaskIdentifier = "spatialSpanMemoryTask"

func buildSpatialSpanMemoryTask() -> ORKTask {
    
    let task = ORKOrderedTask.spatialSpanMemoryTaskWithIdentifier(spatialSpanMemoryTaskIdentifier, intendedUseDescription: demoDescription, initialSpan: 3, minimumSpan: 2, maximumSpan: 15, playSpeed: 1.0, maxTests: 5, maxConsecutiveFailures: 3, customTargetImage: nil, customTargetPluralName: nil, requireReversal: false, options: .None)
    
    return task
}

let booleanQuestionTaskIdentifier = "booleanQuestionTask"
let booleanQuestionStepIdentifier = "booleanQuestionStep"
let demoQuestionString = "Your question goes here."
let demoDetailString = "Additional text can go here."

func buildBooleanQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: booleanQuestionStepIdentifier, title: demoQuestionString, answer: ORKAnswerFormat.booleanAnswerFormat())
    step.text = demoDetailString
    let task = ORKOrderedTask(identifier: booleanQuestionTaskIdentifier, steps: [step])
    
    return task
}

let scaleQuestionTaskIdentifier = "scaleQuestionTask"
let discreteScaleQuestionStepIdentifier = "discreteScaleQuestionStep"
let continuousScaleQuestionStepIdentifier = "continuousScaleQuestionStep"

func buildScaleQuestionTask() -> ORKTask {
    
    let step1 = ORKQuestionStep(identifier: discreteScaleQuestionStepIdentifier, title: demoQuestionString, answer: ORKAnswerFormat.scaleAnswerFormatWithMaxValue(10, minValue: 1, step: 1, defaultValue: NSIntegerMax))
    step1.text = demoDetailString
    
    let step2 = ORKQuestionStep(identifier: continuousScaleQuestionStepIdentifier, title: demoQuestionString, answer: ORKAnswerFormat.continuousScaleAnswerFormatWithMaxValue(5.0, minValue: 1.0, defaultValue:99.0, maximumFractionDigits: 2))
    step2.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: scaleQuestionTaskIdentifier, steps: [step1, step2])
    
    return task
}

let valuePickerQuestionTaskIdentifier = "valuePickerQuestionTask"
let valuePickerQuestionStepIdentifier = "valuePickerQuestionStep"

func buildValuePickerQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: valuePickerQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.valuePickerAnswerFormatWithTextChoices(
            [ORKTextChoice(text: "choice 1", value: "choice 1"),
                ORKTextChoice(text: "choice 2", value: "choice 2"),
                ORKTextChoice(text: "choice 3", value: "choice 3")]))
    step.text = demoDetailString
    
    
    let task = ORKOrderedTask(identifier: valuePickerQuestionTaskIdentifier, steps: [step])
    
    return task
}

let imageChoiceQuestionTaskIdentifier = "imageChoiceQuestionTask"
let imageChoiceQuestionStepIdentifier = "imageChoiceQuestionStep"

func buildImageChoiceQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: imageChoiceQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.choiceAnswerFormatWithImageChoices(
            [ORKImageChoice(normalImage: UIImage(named: "first"), selectedImage: nil, text: "Round Shape", value: "Round Shape"),
                ORKImageChoice(normalImage: UIImage(named: "second"), selectedImage: nil, text: "Square Shape", value: "Square Shape")]))
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: imageChoiceQuestionTaskIdentifier, steps: [step])
    
    return task
}

let textChoiceQuestionTaskIdentifier = "textChoiceQuestionTask"
let textChoiceQuestionStepIdentifier = "textChoiceQuestionStep"

func buildTextChoiceQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: textChoiceQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice,
            textChoices: [ORKTextChoice(text: "choice 1", value: "choice 1"),
                ORKTextChoice(text: "choice 2", value: "choice 2"),
                ORKTextChoice(text: "choice 3", value: "choice 3")]))
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: textChoiceQuestionTaskIdentifier, steps: [step])
    
    return task
}

let numberQuestionTaskIdentifier = "numberQuestionTask"
let numberQuestionStepIdentifier = "numberQuestionStep"
let numberNoUnitQuestionStepIdentifier = "numberNoUnitQuestionStep"

func buildNumberQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: numberQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.decimalAnswerFormatWithUnit("Your unit"))
    step.text = demoDetailString
    step.placeholder = "Your placeholder."
    
    let step2 = ORKQuestionStep(identifier: numberNoUnitQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.decimalAnswerFormatWithUnit(nil))
    step2.text = demoDetailString
    step2.placeholder = "Placeholder without unit."
    
    let task = ORKOrderedTask(identifier: numberQuestionTaskIdentifier, steps: [step, step2])
    
    return task
}

let timeOfDayQuestionTaskIdentifier = "timeOfDayQuestionTask"
let timeOfDayQuestionStepIdentifier = "timeOfDayQuestionStep"

func buildTimeOfDayQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: timeOfDayQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.timeOfDayAnswerFormat())
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier:timeOfDayQuestionTaskIdentifier, steps: [step])
    
    return task
}

let dateTimeQuestionTaskIdentifier = "dateTimeQuestionTask"
let dateTimeQuestionStepIdentifier = "dateTimeQuestionStep"

func buildDateTimeQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: dateTimeQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.dateTimeAnswerFormat())
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: dateTimeQuestionTaskIdentifier, steps: [step])
    
    return task
}

let dateQuestionTaskIdentifier = "dateQuestionTask"
let dateQuestionStepIdentifier = "dateQuestionStep"

func buildDateQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: dateQuestionStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.dateAnswerFormat())
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: dateQuestionTaskIdentifier, steps: [step])
    
    return task
}

let timeIntervalTaskIdentifier = "timeIntervalQuestionTask"
let timeIntervalStepIdentifier = "timeIntervalQuestionStep"

func buildTimeIntervalQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: timeIntervalStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.timeIntervalAnswerFormat())
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: timeIntervalTaskIdentifier, steps: [step])
    
    return task
}

let textIntervalTaskIdentifier = "textQuestionTask"
let textIntervalStepIdentifier = "textQuestionStep"

func buildTextQuestionTask() -> ORKTask {
    
    let step = ORKQuestionStep(identifier: textIntervalStepIdentifier,
        title: demoQuestionString,
        answer: ORKAnswerFormat.textAnswerFormat())
    step.text = demoDetailString
    
    let task = ORKOrderedTask(identifier: textIntervalTaskIdentifier, steps: [step])
    
    return task
}

let formTaskIdentifier = "formTask"
let formStepIdentifier = "formStep"
let formItemIdentifier01 = "formItem01"
let formItemIdentifier02 = "formItem02"

func buildFormTask() -> ORKTask {
    
    let step = ORKFormStep(identifier: formTaskIdentifier, title: demoQuestionString, text: demoDetailString)
    let formItem01 = ORKFormItem(identifier: formItemIdentifier01, text: "Field01", answerFormat: ORKAnswerFormat.integerAnswerFormatWithUnit(nil))
    formItem01.placeholder = "Your placeholder here"
    let formItem02 = ORKFormItem(identifier: formItemIdentifier02, text: "Field02", answerFormat: ORKTimeIntervalAnswerFormat())
    formItem02.placeholder = "Your placeholder here"
    step.formItems = [formItem01, formItem02]
    
    let task = ORKOrderedTask(identifier: formTaskIdentifier, steps: [step])
    
    return task
}

    