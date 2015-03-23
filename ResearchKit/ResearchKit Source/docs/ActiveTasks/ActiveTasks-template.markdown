# Active Tasks

Active tasks invite users to perform activities under partially
controlled conditions, while iPhone sensors are used to collect data.
For example, an active task for analyzing gait and balance might ask
the user to walk a short distance, while collecting accelerometer
sample data on the iPhone.


##Pre-defined Active Tasks

At release, ResearchKit included five pre-defined tasks, which can be
categorized into motor activities, fitness, cognition, and voice,
which are summarized in the following table:

<table>
<caption>Active task modules in ResearchKit</caption>
    <tr>
        <td>Category</td>
        <td>Task</td>
        <td>Sensor</td>
        <td>Data collected</td>
    </tr>
 <tr><td rowspan = 2>Motor activities</td> 
     <td>Gait and Balance (short walk)</td>
     <td>Accelerometer<br>
  Gyroscope</td> 
  <td>Device motion<br>Pedometer</td> 
 </tr>
<tr><td>Tapping speed (Two finger tapping)</td> 
<td>Touch Screen <br>
Accelerometer (optional)
</td> 
  <td>Touch activity<br/>
  </td> 
</tr>
<tr><td>Fitness</td>
 <td>Fitness (Fitness check)</td>
 <td>Accelerometer</td>
<td>Device motion<br>
   <br>Pedometer<br>
    <br>Location<br>
   <br>Heart rate<br>
   </td> 
</tr>
<tr><td>Cognition</td>
<td>Spatial memory (Spatial span memory)</td>
<td>Touch screen</td>
<td>
Touch activity<br>
Correct and actual sequences<br>
</td>
</tr>
<tr><td>Voice</td>
<td>Sustained phonation (Audio)</td>
    <td>Microphone</td>
    <td>Uncompressed audio</td>
</tr>
</table>


#### Options for Predefined Tasks

You can disable the instruction or completion steps automatically
included in the framework when instantiating one of the pre-defined
active tasks by passing an appropriate combination of the
`ORKPredefinedTaskOption` constants.

Other options flags can be used to exclude certain types of data
collection if they are not needed for your study. For example, if you
want the user to perform the fitness task but do not need heart rate
data, you would use `ORKPredefinedTaskOptionExcludeHeartrate`.


#### Fitness

In the [fitness task]([ORKOrderedTask fitnessCheckTaskWithIdentifier:intendedUseDescription:walkDuration:restDuration:options:]), the user walks for a specified duration (usually
several minutes). Sensor data is collected and returned through the
task view controller's delegate. Sensor data can include
accelerometer, device motion, pedometer, location, and heart rate data
where available.

Towards the end of the walk, if heart rate data is available, the user
is asked to sit down and rest for a period. Data collection continues
during the rest period.

All of the data is collected from public CoreMotion and HealthKit
APIs, and serialized to JSON. No analysis is applied to the data by
ResearchKit.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/TaskIntroduction.png" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskIntroduction.png" style="width: 100%;border: solid black 1px;">Instruction step describing what the user must do.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessCountDownStep.png" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskWalkStep.png" style="width: 100%;border: solid black 1px; ">Displays distance and heart rate</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskRestStep.png" style="width: 100%;border: solid black 1px;">The rest step. This is skipped if heart rate data is unavailable.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="FitnessImages/FitnessTaskCompletionStep.png" style="width: 100%;border: solid black 1px;">Confirms completion</p>
<p style="clear: both;">

#### Voice

In the [audio task]([ORKOrderedTask audioTaskWithIdentifier:intendedUseDescription:speechInstruction:shortSpeechInstruction:duration:recordingSettings:options:]), the user makes a sustained sound, and an audio
recording is made. Analysis of the audio data is not included in
ResearchKit, but might naturally involve looking at the power spectrum
and how it relates to the ability to produce certain
sounds. ResearchKit uses the `AVFoundation` framework to collect this
data and to present volume indication during recording. No data
analysis is done by ResearchKit; you can define your analysis on this
task as per requirements.


<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AboutTaskIntroduction.png" alt="Welcome Screen"  style="width: 100%;border: solid black 1px; ">Instruction step giving motivation for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskIntroduction.png" alt="Instruction Screen" style="width: 100%;border: solid black 1px;">Instruction step describes user action during the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskCountdownStep.png" alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Count down a specified duration to begin the task</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskStep.png" alt="Task Screen" style="width: 100%;border: solid black 1px; ">Displaying a graph during audio playback (Audio collection step)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="AudioImages/AudioTaskCompletionStep.png"  alt="Task Completion Screen" style="width: 100%;border: solid black 1px;">Confirms completion</p><p style="clear: both;">

#### Gait and Balance

In the [gait and balance task]([ORKOrderedTask
shortWalkTaskWithIdentifier:intendedUseDescription:numberOfStepsPerLeg:restDuration:options:]),
the user walks for a short distance, which may be indoors. You might
use this semi-controlled task to collect objective measurements which
can be used to estimate stride length, smoothness, sway, and other
aspects of the participant's walking.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Instruction step giving motivation and instruction for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep2.png" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep3.png" style="width: 100%;border: solid black 1px;">Asking using to walk screen</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep4.png" style="width: 100%;border: solid black 1px; ">Asking using to walk screen</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep5.png" style="width: 100%;border: solid black 1px;">Asking user to rest screen</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="ShortWalkTaskImages/ShortWalkTaskStep6.png" style="width: 100%;border: solid black 1px;">Task completion screen</p>
<p style="clear: both;">


####  Tapping Speed

In the [tapping task]([ORKOrderedTask twoFingerTappingIntervalTaskWithIdentifier:intendedUseDescription:duration:options:]), the user rapidly alternates between tapping two
targets on the touch screen. The resulting touch data can be used to
assess basic motor capabilities such as speed, accuracy, and rhythm.

Touch data, and optionally accelerometer data from CoreMotion, are
collected using public APIs. No analysis is preformed by ResearchKit
on the data.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Motivation for the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep2.png" style="width: 100%;border: solid black 1px;">Count down a specified duration into the task.</p><p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep3.png" style="width: 100%;border: solid black 1px; ">The user rapidly taps on the targets.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="TwoFingerTappingTaskImages/TwoFingerTappingTaskStep4.png" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="clear: both;">

#### Spatial Memory

In the [spatial memory task]([ORKOrderedTask spatialSpanMemoryTaskWithIdentifier:intendedUseDescription:initialSpan:minimumSpan:maximumSpan:playSpeed:maxTests:maxConsecutiveFailures:customTargetImage:customTargetPluralName:requireReversal:options:]),
the user is asked to observe and then recall pattern sequences of
increasing length in a game-like environment. It collects data that
can be used to assess on visuospatial memory and executive function.

The "span" (length of the pattern sequence) is automatically varied
during the task, increasing after successful completion of a sequence,
and decreasing after failures, in the range from `minimumSpan` to
`maximumSpan`.  The `playSpeed` property lets you control the speed of sequence
playback, and the `customTargetImage` property lets you customize the shape of the
tap target. The game finishes when either `maxTests` tests have been
completed, or the user has made `maxConsecutiveFailures` errors in a
row.

The results collected are scores derived from the game, the details of
the game, and the touch inputs made by the user.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep1.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px; ">Gives the purpose of the task.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep2.png" alt="Instruction step" style="width: 100%;border: solid black 1px;">Describes what the user must do.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3.png" alt="Initial sequence playback screen" style="width: 100%;border: solid black 1px;">The flowers light up in sequence.</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_1.png" alt="Recall sequence screen" style="width: 100%;border: solid black 1px; ">The user must recall the sequence.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_2.png" alt="Consecutive failure screen" style="width: 100%;border: solid black 1px;">If they make a mistake, they will be offered a new pattern.</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep3_3.png" alt="Welcome/introduction Screen" style="width: 100%;border: solid black 1px;">The user is offered a shorter sequence.</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SpatialSpanMemoryTaskImages/SpatialMemoryTestStep4.png" alt="Task Completion screen" style="width: 100%;border: solid black 1px;">Task completion</p>
<p style="clear: both;">



### Getting the Data

The data collected in active tasks is recorded to a hierarchy of
`ORKResult` objects in memory. It is up to you to serialize this
hierarchy for storage or transmission in a way appropriate to your
application.

When the data collected might be too large for in-memory delivery, an
`ORKFileResult` is included in the hierarchy instead. The file result
references a file in the output directory (specified via the
`outputDirectory` property of `ORKTaskViewController`). For example,
recorders which log at high sample rates, such as the accelerometer,
log directly to a file like this.

The recommended approach for handling file-based output is to create a
new directory per task and to remove it once you have processed the
results of the task.

Active steps support attaching recorder configurations
(`ORKRecorderConfiguration`). A recorder configuration defines a type of
data that should be collected for the duration of the step from a sensor or
a database on the device. For example:

* The pedometer sensor returns a `CMPedometerData` object that provides step counts computed by the motion coprocessor on supported devices
* The accelerometer sensor returns a `CMAccelerometerData` object that provides raw accelerometer samples indicating the forces on the device.
* Fused sampled accelerometer, gyroscope, and magnetometer device motion returns a `CMDeviceMotion` object that provides information about the orientation and movement of the device.
* HealthKit sample types, such as heart rate.
* Location data from CoreLocation, fused from GPS, Wifi and cell tower information.


The recorders used by ResearchKit's pre-defined active tasks always use
`NSFileProtectionCompleteUnlessOpen` while writing data to disk, and
then change the file protection level on any files generated to
`NSFileProtectionComplete` when recording is finished.


### Creating new Active Tasks

You can also build your own custom active tasks, by creating your own
custom subclasses of `ORKActiveStep` and
`ORKActiveStepViewController`. In doing this, you can follow the example of
the active steps in the predefined tasks that are already in ResearchKit.

Some of the steps used in the predefined tasks may also be useful to
you.  For example, the `ORKCountdownStep` displays a timer that counts
down with animation for the step duration. To give another example,
the `ORKCompletionStep` object displays a confirmation that the task
is completed:

<center>
<figure>
<img src="FitnessImages/FitnessTaskCompletionStep.png" width="25%" alt="Completion step" align="middle" style="border: solid black 1px;" />
  <figcaption> <center>Example of a completion step.</center></figcaption>
</figure>
</center>

