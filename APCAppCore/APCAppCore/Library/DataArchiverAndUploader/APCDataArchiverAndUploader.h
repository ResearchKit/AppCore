//
// APCDataArchiverAndUploader.h
// AppCore
//
// Copyright (c) 2015 Apple, Inc. All rights reserved.
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

#import <Foundation/Foundation.h>



/**
 Uploads .json and other files to Sage, .zipping and encrypting
 them first.
 
 To use this:  call one of its +upload methods.  It will queue
 your objects to be archived and uploaded, return to you immediately,
 and then begin processing those objects.
 
 Currently, this class only supports uploading a single
 dictionary.  It should be straightforward to add other features
 we know we need:

 - upload multiple dictionaries

 - upload precomputed files (tapping data, air-quality data, etc.)

 - encrypt the contents of a .zip file, as well as the
   entire .zip file (air-quality data)


 ----------
 Goals
 ----------

 This class is intended to upload all types of data to Sage.
 It blends features from several other classes in this project:
 the APCDataArchiver in AppCore, the APHAirQualityDataModel in
 Asthma, and some other features from other uploaders around the
 AppCore.  Hopefully, it can become a superclass of those other
 classes, or at least provide generic, streamlined tools those
 other classes can use.

 Let's add "upload..." methods to this class as needed.

 Eventually, this class will support any third-party server,
 not just Sage; and those upload methods will probably end up
 in DataSubstrate.


 ----------
 Behind the Scenes
 ----------

 (1) When you call +upload, we create an ArchiverAndUploader
 object.  It starts asynchronously processing the objects you
 passed it.  If all goes well, it shoves those items into a
 .zip file, encrypts the file, and ships that file to Sage by
 calling Sage's "Bridge SDK."  When Bridge gets back to us
 with a status report, the Archiver deletes up any temporary
 files and directories it made, and frees itself from RAM.
 
 (2) You can call +upload as often as you like.  Each call
 creates a separate ArchiverAndUploader.  All of these objects
 use the same, global operationQueue to do their work.
 Currently, that queue is set to allow only one operation
 at a time, which I think will aid debugging and CPU load.
 We can experiment with increasing the number of simultaneous
 operations it allows.
 
 (3) This .zip-and-ship process has about 8 steps.  Each step
 returns a Boolean saying whether it worked, and an NSError
 representing any problems.  All errors are custom-crafted
 for this class; it wraps any errors from any other classes
 into an ArchiverAndUploader error.  Each of those steps
 behaves the same way internally:  it has one or more tasks
 to do, each of which returns a Boolean and an error.
 In every case, we stop processing as fast as possible after
 getting an error, and all errors and successes end up falling
 into the same "clean up" method.


 ----------
 How'd we get here?
 ----------

 Here's how this class relates to other classes scattered
 around our application suite, and the reason I felt it would
 be useful to create a new class:
 
 (1)  The AppCore DataArchiver was designed to create .zip
      files of ResearchKit output.  It's been robustified and
      enhanced in various ways, but stayed true to that need.
      It did *not* address the need to *upload* data to Sage;
      it only .zips that data.
 
 (2)  This means that everyone that needs to upload anything
      does it in their own way.  They call the Archiver to
      .zip their stuff, and then ship it to Sage by copying and
      pasting one of a couple of different method calls.
 
 (3)  The Asthma DataModel, a much more recent piece, combined
      pieces of all of that.  It used some evolving generalized
      pieces in the AppCore Archiver, and incorporated a
      streamlined version of uploader logic from other parts
      of the app.  It's also bound up (completely appropriately)
      with the needs of the Asthma app.
 
 (4)  Same goes for the PassiveDataCollectors.
 
 This new class started its life as an uploader for one very
 specific type of data:  the output of the MedicationTracker.
 However, since we can now see the above evolution, I think
 it makes sense to have a general-purpose archiver-and-
 uploader -- continuing the trend started by the Asthma Model
 class, and generalizing it further.
 
 So while I'll try hard NOT to overengineer this, I'll
 also try to keep it general enough that we can find 
 naturally-occurring subclass and superclass relationships
 between this new piece and the other pieces above.
 
 Many thanks to the programmers who started and evolved all
 of the above classes!
 */

typedef void(^UploaderCallbackWhenCompleted)(NSError *error);

@interface APCDataArchiverAndUploader : NSObject


/**
 .zips and uploads the specified dictionary to Sage.
 
 The dictionary will be recursively converted to values that
 can be serialized to JSON, and will then be converted to JSON.
 The JSONified contents will then be stored as an entry in
 the .zip file, using a filename specified in the "item" key
 in the dictionary.
 
 One requirement and one caveat for you:

 (a) The requirement:  the dictionary must contain a key named
 "item", whose value will become the name of the file containing
 the JSON-ified contents of that dictionary.  Please use a
 string value for this key which can be used as a filename:
 "useful_question_data" is fine, "hey! cool stuff, dude!" is
 less so.  Do not add a file extension; the file will
 automatically receive the extension "json".

 (b) The caveat:  the dictionary will be converted to JSON in ways
 highly specific to this application suite and the fact that we're
 uploading to Sage.  For example, NSDate objects will be converted
 to a specific ISO-8601 format (like "2014-01-31T12:34:56-0800"),
 strings which contain arrays of integers will be converted to
 arrays of actual integers, and CoreData objectIDs will be
 converted to a UUID-like equivalent.

 @param dictionary  A dictionary to upload.  The dictionary will
 become a .json file, stored in a .zip file.  See the description
 of this method, above, for details.

 @param taskIdentifier  A human-readable string identifying the
 purpose of this upload.  May be nil.  Note that the value, in
 principle, should not be nil -- the point is to uniquely identify
 your upload.  But that's a choice made by you and the people on
 the server team who will receive your upload; the tool won't
 prevent you from sending "nil" if you wish.

 @param taskRunUuid  A UUID representing a unique ID for this
 run of the task identified by taskIdentifier.  May be nil.
 */
+ (void) uploadDictionary: (NSDictionary *) dictionary
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUuid: (NSUUID *) taskRunUuid;

/**
  * @brief Same as -uploadDictionary:withTaskIdentifier:andTaskRunUuid
  *        with additional arguments to supply a queue and a block.
  *
  * @param completionQueue   A queue that will be used for executing
  *                          the block.
  * @param withCompletion    A block that will be executed upon completion.
  *
  */
+ (void) uploadDictionary: (NSDictionary *) dictionary
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUUID: (NSUUID *) taskRunUUID
          completionQueue: (NSOperationQueue *) completionQueue
           withCompletion: (UploaderCallbackWhenCompleted) completion;

/**
 .zips and uploads the specified file to Sage.  This method
 takes ownership of the file you specify; it will move the file
 to a private directory, and upload it from there, on a separate
 thread.  It will attempt to move the file while still on the
 thread from which you called it, so that by the time this method
 returns, you can do whatever you need to do next with the folder
 and path where that file used to be.

 We can evolve this design as needed.  This suits our current
 needs.
 
 This method simply calls the plural method,
 +uploadFilesAtPaths:returningError:.
 
 @return YES if able to move the file, NO if not.  A YES here does
 NOT mean the upload worked; this merely says whether the uploader
 was able to grab the file.  If we return NO, the file becomes
 your responsibility (again), to do with as you please.  For
 your convenience, the path to the file will also be available
 in the returned error object.
 
 @param path  The path of the file to upload.

 @param taskIdentifier  A human-readable string identifying the
 purpose of this upload.  May be nil.  Note that the value, in
 principle, should not be nil -- the point is to uniquely identify
 your upload.  But that's a choice made by you and the people on
 the server team who will receive your upload; the tool won't
 prevent you from sending "nil" if you wish.

 @param taskRunUuid  A UUID representing a unique ID for this
 run of the task identified by taskIdentifier.  May be nil.

 @param errorToReturn  A pointer to the variable for an error
 object.  If there's a problem *obtaining* the file, we'll return
 the error here (and print it to the console).  Pass nil if you
 don't care about the error.
 */
+ (BOOL) uploadFileAtPath: (NSString *) path
       withTaskIdentifier: (NSString *) taskIdentifier
           andTaskRunUuid: (NSUUID *) taskRunUuid
           returningError: (NSError * __autoreleasing *) errorToReturn;


/**
 .zips and uploads the specified files to Sage.  This method
 takes ownership of the files you specify; it will move the files
 to a private directory, and upload them from there, on a separate
 thread.  It will attempt to move the files while still on the
 thread from which you called it, so that by the time this method
 returns, you can do whatever you need to do next with the folder
 and path where those files used to be.

 We can evolve this design as needed.  This suits our current
 needs.

 @return YES if able to move the file, NO if not.  A YES here does
 NOT mean the upload worked; this merely says whether the uploader
 was able to grab the file.  If we return NO, the file becomes
 your responsibility (again), to do with as you please.  For
 your convenience, the path to the file will also be available
 in the returned error object.

 @param path  The paths of the files to upload.  The files must 
 have different filenames-and-extensions -- please don't have
 two files named "temp.txt", for example.

 @param taskIdentifier  A human-readable string identifying the
 purpose of this upload.  May be nil.  Note that the value, in
 principle, should not be nil -- the point is to uniquely identify
 your upload.  But that's a choice made by you and the people on
 the server team who will receive your upload; the tool won't
 prevent you from sending "nil" if you wish.

 @param taskRunUuid  A UUID representing a unique ID for this
 run of the task identified by taskIdentifier.  May be nil.

 @param errorToReturn  A pointer to to the variable for an error
 object.  If there's a problem obtaining the file, we'll return
 the error here (and print it to the console).  Pass nil if you
 don't care about the error.  If you passed more than one file,
 the error's userInfo dictionary will contain an array of the
 paths we didn't move.  These paths are now your responsibility
 (again).  Any paths we managed to move, we'll delete, as if
 they had been uploaded.
 */
+ (BOOL) uploadFilesAtPaths: (NSArray *) path
         withTaskIdentifier: (NSString *) taskIdentifier
             andTaskRunUuid: (NSUUID *) taskRunUuid
             returningError: (NSError * __autoreleasing *) errorToReturn;

@end














