#Creating Surveys

A survey task is a collection of step objects (`ORKStep`) representing
a sequence of questions, such as "What medications are you taking?" or
"How many hours did you sleep last night?". You can collect results
for the individual steps or for the entire task.

The steps for creating a task to present a survey are:

1. <a href="#create">Create one or more steps</a>
2. <a href="#task">Create a task</a>
3. <a href="#results">Collect results</a>

##1. Create Steps<a name="create"></a>

The survey module provides a single-question step (`ORKQuestionStep`)
and a form step that can contain more than one item
(`ORKFormStep`). You can also use an instruction step
(`ORKInstructionStep`) to introduce the survey or provide specific
instructions.

Every step has its own step view controller that defines the UI
presentation for that type of step. When a task view controller needs
to present a step, it instantiates and presents the right step view
controller for the step. If needed, you can customize the details of
each step view controller, such as button titles and appearance, by
implementing task view controller delegate methods (see
`ORKTaskViewControllerDelegate` ).

### Instruction Step

An instruction step explains the purpose of a task and provides instructions for the user. An
`ORKInstructionStep` object includes an identifier, title,
text, detail text, and an image.  Since an instruction step does not
collect any data, it yields an empty `ORKStepResult` that nonetheless
records how long the instruction was on screen.

    ORKInstructionStep *step =
      [[ORKInstructionStep alloc] initWithIdentifier:@"identifier"];
    step.title = @"Selection Survey";
    step.text = @"This survey can help us understand your eligibility for the fitness study";

Creating a step as shown in the code above, including it in a task, and
presenting with a task view controller, yields something like this:

<center>
<figure>
<img src="SurveyImages/InstructionStep.png" width="25%" alt="Completion step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Example of an instruction step.</center></figcaption>
</figure>
</center>

### Question Step

A question step (`ORKQuestionStep`) presents a single question,
composed of a short `title` and longer, more descriptive `text`. The
type of data entry is configured by setting the answer format. You can
also provide an option for the user to skip the question with the
step's `optional` property.

For numeric and text answer formats, the question step's placeholder
property specifies a short hint that describes the expected value of
an input field.

A question step yields a step result that, like the instruction step's
result, indicates how long the user had the question on screen. It
also has a child, an `ORKQuestionResult` subclass that reports the
user's answer.

The following code configures a simple numeric question step.

    ORKNumericAnswerFormat *format =
      [ORKNumericAnswerFormat integerAnswerFormatWithUnit:@"years"];
    format.minimum = @(18);
    format.maximum = @(90);
    ORKQuestionStep *step =
      [ORKQuestionStep questionStepWithIdentifier:kIdentifierAge
                                            title:@"How old are you?"
                                           answer:format];

Adding this question step to a task and presenting the task produces
a screen that looks like this:

<center>
<figure>
<img src="SurveyImages/QuestionStep.png" width="25%" alt="Question step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Example of a question step.</center></figcaption>
</figure>
</center>


####Form Step

When the user needs to answer several related questions together, it
may be preferable to use a form step (`ORKFormStep`) in order to present them all on
one page.  Form steps support all the same answer formats as question
steps, but can contain multiple items (`ORKFormItem`), each with its
own answer format.

Forms can be organized into sections by incorporating extra dummy form
items with only a title. See the `ORKFormItem` reference documentation
for more details.

The result of a form step is similar to the result of a question step,
except that it will contain one question result for each form
item. The results are matched to their corresponding form items using
their identifiers (the `identifier` property).

For example, to create a form requesting some basic details, using
default values extracted from HealthKit to accelerate data entry:

    ORKFormStep *step =
      [[ORKFormStep alloc] initWithIdentifier:kFormIdentifier
                                        title:@"Form"
                                         text:@"Form groups multi-entry in one page"];
    NSMutableArray *items = [NSMutableArray new];
    ORKAnswerFormat *genderFormat =
      [ORKHealthKitCharacteristicTypeAnswerFormat
       answerFormatWithCharacteristicType:
         [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]];
    [items addObject:
      [[ORKFormItem alloc] initWithIdentifier:kGenderItemIdentifier
                                         text:@"Gender"
                                 answerFormat:genderFormat];

    // Include a section separator
    [items addObject:
      [[ORKFormItem alloc] initWithSectionTitle:@"Basic Information"]];

    ORKAnswerFormat *bloodTypeFormat =
      [ORKHealthKitCharacteristicTypeAnswerFormat
       answerFormatWithCharacteristicType:
         [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType]];
    [items addObject:
      [[ORKFormItem alloc] initWithIdentifier:kBloodTypeItemIdentifier
                                         text:@"Blood Type"
                                 answerFormat:bloodTypeFormat];

    ORKAnswerFormat *dateOfBirthFormat =
      [ORKHealthKitCharacteristicTypeAnswerFormat
       answerFormatWithCharacteristicType:
         [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth]];
    ORKFormItem *dateOfBirthItem =
      [[ORKFormItem alloc] initWithIdentifier:kDateOfBirthItemIdentifier
                                         text:@"DOB"
                                 answerFormat:dateOfBirthFormat];
    dateOfBirthItem.placeholder = @"DOB";
    [items addObject:dateOfBirthItem];

    // ... And so on, adding additional items
    step.items = items;


The code above gives you something like this:
<center>
<figure>
<img src="SurveyImages/FormStep.png" width="25%" alt="Form step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Example of a form step.</center></figcaption>
</figure>
</center>


### Answer Format

In ResearchKit, an answer format defines how the user will be asked to
answer a question or an item in a form.  For example, consider a
survey question such as "On a scale of 1 to 10, how much pain do you
feel?" The answer format for this question would naturally be a
continuous scale on that range, so you can use
`ORKScaleAnswerFormat`, and set its `minimum` and `maximum` properties
to reflect the desired range.

<table>
<caption>Supported answer formats in ResearchKit</caption>
    <tr>
        <td>Answer format</td>
        <td> UI representation </td>
    </tr>
 <tr>
 <td><pre>ORKScaleAnswerFormat</pre></td>
 <td><img src="SurveyImages/ScaleAnswerFormat.png" width="25%" alt="Scale answer format"  style="float: left;border: solid black 1px;" />
 </td>
 </tr>
 <tr>
 <td><pre>ORKBooleanAnswerFormat</pre></td>
 <td><img src="SurveyImages/BooleanAnswerFormat.png" width="25%" alt="Boolean answer format"  style="float: left;border: solid black 1px;"/>
 </td>
 </tr>
  <tr>
 <td><pre>ORKValuePickerAnswerFormat</pre></td>
 <td><img src="SurveyImages/ValuePickerAnswerFormat.png" width="25%" alt=" Value picker answer format"  style="float: left;border: solid black 1px;"/>
 </td> </tr>
  <tr>
 <td><pre>ORKImageChoiceAnswerFormat</pre></td>
 <td><img src="SurveyImages/ImageChoiceAnswerFormat.png" width="25%" alt=" ImageChoice answer format"  style="float: left;border: solid black 1px;"/>
 </td>
 </tr>
  <tr>
 <td><pre>ORKTextChoiceAnswerFormat</pre></td>
 <td>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextChoiceAnswerFormat_1.png" alt=" TextChoice answer format" style="width: 100%;border: solid black 1px; "></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextChoiceAnswerFormat_2.png" alt=" TextChoice answer format"  style="width: 100%;border: solid black 1px;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;">
<p style="clear: both;">  
 </td>
 </tr> <tr>
 <td><pre>ORKNumericAnswerFormat</pre></td>
 <td><img src="SurveyImages/NumericAnswerFormat.png" width="25%" alt=" Numeric answer format"  style="float: left;border: solid black 1px;"/>
 </td>
 </tr>
  <tr>
 <td><pre>ORKTimeOfDayAnswerFormat</pre></td>
 <td><img src="SurveyImages/TimeOfTheDayAnswerFormat.png" width="25%" alt=" TimeOfTheDay answer format"  style="float: left;border: solid black 1px;"/> </td>
 </tr>
  <tr>
 <td><pre>ORKDateAnswerFormat</pre></td>
 <td><img src="SurveyImages/DateAnswerFormat.png" width="25%" alt=" DateAnswer answer format"  style="float: left;border: solid black 1px;"/>
 </td>
 </tr>
  <tr>
 <td><pre>ORKTextAnswerFormat</pre></td>
 <td>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextAnswerFormat_1.png" alt=" DateAnswer answer format" style="width: 100%;border: solid black 1px; "></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextAnswerFormat_2.png" alt=" DateAnswer answer format"  style="width: 100%;border: solid black 1px;"></p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;">
<p style="clear: both;"> 
 </td>
 </tr>
</table>

<p></p>

In addition to the preceding answer formats, ResearchKit provides
special answer formats for asking questions about quantities or
characteristics that the user might already have stored in the Health
app. When a HealthKit answer format is used, the task view controller
automatically presents a Health data access request to the user (if
they have not already granted access to your app). The presentation
details are populated automatically, and, if the user has granted
access, the field defaults to the current value retrieved from their
Health database.

## 2. Create a Survey Task<a name="task"></a>

Once you create one or more steps, create an `ORKOrderedTask` to
hold them. In this example, we have put a boolean step in a task:

    // Create a boolean step to include in the task.
    ORKStep *booleanStep = [[ORKQuestionStep alloc] initWithIdentifier:kNutritionIdentifier];
    booleanStep.title = @"Do you take nutritional supplements?";
    booleanStep.answerFormat = [ORKBooleanAnswerFormat new];
    booleanStep.optional = NO;

    // Create a task wrapping the boolean step.
    ORKOrderedTask *task =
      [[ORKOrderedTask alloc] initWithIdentifier:kTaskIdentifier
                                           steps:@[booleanStep]];


You must assign a string identifier to each step, and this identifier
ought to be unique, at least within the task. The step identifier is
the key that connects a step in the task hierarchy with the step
result in the result hierarchy.

To present the task, attach it to a task view controller and present
it. This snippet shows how one might then create a task view
controller and present it modally:

    // Create a task view controller using the task and set a delegate.
    ORKTaskViewController *taskViewController =
      [[ORKTaskViewController alloc] initWithTask:task taskRunUUID:nil];
    taskViewController.delegate = self;

    // Present the task view controller.
    [self presentViewController:taskViewController animated:YES completion:nil];


<p><i>Note: `ORKOrderedTask` assumes that you will always present all the questions,
and will never decide what question to show based on previous answers.
To introduce conditional logic, you will need to either subclass
`ORKOrderedTask` or implement the `ORKTask` protocol yourself.</i></p>



##3. Collect Results<a name="results"></a>

The results of a task are found on the `result` property of the task
view controller.

Each step view controller that the user views produces a step result
(`ORKStepResult`). The task view controller collates these together as
the user navigates through the task, in order to produce an
`ORKTaskResult`.

Both the task result and step result are "collection" results, in that
they can contain other result objects. For example, a task result
contains an array of step results.

The results contained in a step result vary depending on the type of
step. For example, a question step produces a question result
(`ORKQuestionResult`); a form step produces one question result for
every form item; and an active task with recorders generally produces
one result for each recorder. 

The resulting hierarchy of results corresponds closely to the input
model hierarchy of task and steps:


<center>
<figure>
<img src="SurveyImages/ResultsHierarchy.png" width="25%" alt="Result hierarchy  style="border: solid black 1px;"/>
  <figcaption> <center>Example of a form step.</center></figcaption>
</figure>
</center>


Among other properties, every result has an identifier. This
identifier is what connects the result to the model object (task,
step, form item, or recorder) that produced it. Every result also
includes start and end times, using the `startDate` and `endDate`
properties respectively. These can be used to infer how long the user
spent on the step.

 
#### Step Results that Determine the Next Step

Sometimes it's important to know the result of a step before
presenting the next step.  For example, suppose a step asks "Do you
have a fever?". If you do, the next question might be "What is your
temperature now?"; otherwise it might be, "Do you have any additional
health concerns?"

The following example demonstrates how one might subclass
`ORKOrderedTask` to provide a different set of steps depending on the
user's answer to a Boolean question. This shows only the step after
step method; but a corresponding implementation of "step before step"
is usually necessary.

    - (ORKStep *)stepAfterStep:(ORKStep *)step
                    withResult:(id<ORKTaskResultSource>)result {
        NSString *ident = step.identiifer;
        ORKStepResult *stepResult = [result stepResultForStepIdentifier:ident];  
        if ([ident isEqualToString:self.qualificationStep.identifier])
        {
            ORKStepResult *stepResult = [result stepResultForStepIdentifier:ident];
            ORKQuestionResult *result = (ORKQuestionResult *)[stepResult firstResult];
            if ([result isKindOfClass:[ORKBooleanQuestionResult class]])
            {
                ORKBooleanQuestionResult *booleanResult = result;
                NSNumber *booleanAnswer = booleanResult.booleanAnswer;
                if (booleanAnswer )
                {
                    return booleanAnswer.boolValue ? self.regularQuestionStep : self.terminationStep;
                }
            }
        }
        return [super stepAfterStep:step withResult:result];
    }
     

#### Saving Results on Task Completion

Once the task is completed, you can save or upload the results. This
will likely include serializing the result hierarchy in some form,
either using the built-in `NSSecureCoding` support, or to another
format appropriate for your application.

If your task can produce file output, the files will generally be
referenced by an `ORKFileResult`, and they will all lie in the output
directory that you set on the task view controller. After completing a
task, one possible implementation might be to serialize the result
hierarchy into the output directory, zip up the entire output
directory, and share it onward.

In the following example, the result is archived with
`NSKeyedArchiver` on successful completion.  If you choose to support
saving and restoring tasks, the user may save the task, so this
example also demonstrates how to obtain the restoration data that
would later be needed to restore the task.

    - (void)taskViewController:(ORKTaskViewController *)taskViewController
           didFinishWithResult:(ORKTaskViewControllerResult)result
                         error:(NSError *)error
    {
        switch (result) {
        case ORKTaskViewControllerResultCompleted:
            // Archive the result object first
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:taskViewController.result];
            
            // Save the data to disk with file protection
            // or upload to a remote server securely.

            // If any file results are expected, also zip up the outputDirectory.
            break;
        case ORKTaskViewControllerResultFailed:
        case ORKTaskViewControllerResultDiscarded:
            // Generally, discard the result.
	    // Consider clearing the contents of the output directory.
            break;
        case ORKTaskViewControllerResultSaved:
            NSData *data = [taskViewController restorationData];
            // Store the restoration data persistently for later use.
            // Normally, keep the output directory for when you will restore.
            break;
        }
    }