#ResearchKit Programming Guide

ResearchKit is an open source software framework that makes it easy
for app developers and researchers to create apps for medical
research. This new framework takes advantage of the sensors and
capabilities of iPhone to track movement, take measurements, and
record data. Users can perform activities and generate data from
anywhere.

##Modules   

ResearchKit provides three customizable modules that address the most
common elements of medical studies: surveys, informed consent, and
active tasks. You can use these modules as they are, build on them,
and even create completely new modules of your own.

###Surveys

The survey module's predefined user interface lets you quickly build
surveys simply by specifying the questions and types of answers. The
survey module is already localized, so all you need to do is localize
your questions. See [Creating Surveys](Survey-template).

###Informed Consent

Participants in research studies are often asked to share sensitive
information as part of their enrollment. That’s why it’s critical to
clarify exactly what users need to provide and who will have access to
their information. ResearchKit provides templates that you can
customize to explain the details of your study to get participant's
signature.

* If your study has obtained a waiver for informed consent, you can
still show a visual consent flow to provide detailed information
without requiring a signature.
* If your study requires informed consent, you can customize the
informed consent module with language from your ethics review board
and use the ResearchKit signature template to user signatures. You
also have the option to generate a PDF of the signed form and provide
it to the user.

See [Creating an Informed Consent Document](InformedConsent-template).

### Active Tasks

Some studies may need data beyond survey questions or the passive data
collection capabilities of HealthKit and CoreMotion APIs. Active tasks
invite users to perform activities under partially-controlled
conditions while iPhone sensors actively collect data. To learn more
about Active task, see [Active Tasks](ActiveTasks-template).

##Tasks and Steps

A task in ResearchKit can be a simple ordered sequence of steps, or it
can be dynamic, with previous results informing what is presented. The
task view controller supports saving progress in the middle of a long
task and restoring it later, as well as UI state restoration to
prevent data loss if the user switches out of your app in the middle
of a task.

Whether your app is giving instructions, presenting a form or survey,
obtaining consent, or running an active task, everything in
ResearchKit is a collection of steps (`ORKStep` objects), which
together form a task (an `ORKTask` object). To present a task,
attach the task to a task view controller
(`ORKTaskViewController`). When the user completes a step in a task,
the task view controller generates a step result object
(`ORKStepResult`) that records the start and end time for that step,
and any results from the step.
 
<center><img src="overview.png" width="80%" alt="ResearchKit Overview"/></center>

In a simple app, you can build up your tasks directly in code, collect
the results, and serialize to disk for later manual collection and
analysis. A large-scale deployment might dynamically download predefined
surveys from a server and de-serialize to produce a ResearchKit object
hierarchy. Similarly, results from tasks can be serialized and
uploaded to a server for later analysis.

##Current Limitations

The ResearchKit feature list will continue to grow as useful modules
are contributed by the community.  Keep in mind that ResearchKit
currently doesn’t include:

* Passive background data collection. APIs like HealthKit and
  CoreMotion already support this.
* Secure communication mechanisms between your app and your server.
* The ability to schedule surveys and active tasks for your
  participants.
* A defined data format for how ResearchKit structured data is
  serialized. All ResearchKit objects conform to the NSSecureCoding
  protocol, and sample code exists outside the framework for
  serializing objects to JSON.
* Automatic compliance with international research regulations and
  HIPAA guidelines. This compliance is the researcher’s
  responsibility.

