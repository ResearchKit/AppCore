This is the API documentation for ResearchKit. For an overview
of ResearchKit and a more general guide to using and extending
the framework, see the [Programming Guide](Overview).


Constructing tasks
--------------------

ResearchKit tasks are constructed using a hierarchy of model
objects.

At the root of the hierarchy is an ORKOrderedTask (or another ORKTask
implementation). The task defines the order in which steps are
presented, and how progress through the task is represented.

The children of a task are steps, which are subclasses of
ORKStep. Most steps are purely for data presentation or data entry,
but some also include some data collection --- these are ORKActiveStep
subclasses.

The survey step classes, ORKQuestionStep and ORKFormStep, describe
the question to be asked. The format of the answer is modelled with
subclasses of ORKAnswerFormat.


Presenting tasks
--------------------

To present a task, we create an ORKTaskViewController and present it.
The ORKTaskViewController then manages the task, and returns the result
back via delegate methods.

For each step, the ORKTaskViewController instantiates an appropriate
subclass of ORKStepViewController to display it.


Getting results
--------------------

The `result` property of ORKTaskViewController gives access to the results
of the task, both while the task is in progress, and on completion of 
the task.

Results are constructed with a hierarchy similar to the task model
hierarchy. ORKTaskResult is the root of the hierarchy, and ORKStepResult
objects form the immediate children.

For survey question steps, the answers collected are in reported as
ORKQuestionResult objects which are children of the ORKStepResult.
Active steps may include additional result objects as children,
depending on the set of recorders involved on the step.


Pre-defined active tasks
--------------------

A category on ORKOrderedTask provides factory methods for generating
ORKOrderedTask instances corresponding to ResearchKit's pre-defined
active tasks.


Informed consent
--------------------

The informed consent features in ResearchKit are implemented using three
special steps that can be added to tasks:

* ORKVisualConsentStep. This provides an animated visual consent flow.

* ORKConsentSharingStep. This is a special question step with
  pre-defined translations, which can be used to establish user preferences
  regarding how widely their data should be shared.

* ORKConsentReviewStep. This step makes the consent document available
  for review, and then provides facilities for collecting the user's
  name and scribbled signature.

To construct either the ORKVisualConsentStep or the ORKConsentReviewStep,
a consent document model, ORKConsentDocument, is also needed.
