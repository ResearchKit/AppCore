// 
//  APCMedicationUltraSimpleSelfInflator.h 
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
 
//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/**
 You'll receive one of these when you call +saveObjects:toFileWithName:completion:.
 */
typedef void (^APCMedicationFileSaveCallback)(BOOL theSaveWorked, NSTimeInterval operationDuration);


@interface APCMedicationUltraSimpleSelfInflator : NSObject


/*
 Data for storing and retrieving from disk.
 This name is significant, in my little world:
 - "uniqueId" is a known prefix.
 - "uniqueIdOfXXXX" says:  please find and load the property of name XXXX with
   the specified ID.  (I think.  Evolving.)
 */
@property (nonatomic, strong) NSNumber *uniqueId;


/**
 Looks for the specified filename in the bundle,
 and attempt to inflate a bunch of instances of this
 class from the array of dictionaries in that file.
 */
+ (NSArray *) inflatedItemsFromPlistFileWithName: (NSString *) fileName;

+ (instancetype) inflateFromPlistEntry: (NSDictionary *) plistEntry;

/**
 Saves an array of objects to a file on the file system.  The objects
 must be subclasses of this class (SimpleInflator).
 
 About threading:

 -  This method returns almost-immediately, and performs the
    "save" operation in the background.  (..Or, actually, on
    a queue you specify.  It could be the main thread.  But,
    like, don't do that.  :-))

 -  This method first copies the pointers in the array you
    specify while still on the thread from which you called it.
 
 -  It then jumps to the queue you specify, performs the "save"
    operation, and calls you back while still on that queue.
 
 This means, for example, that if you call several successive
 "save" operations on the same queue, your own callback to the
 first "save" will execute before the second "save" starts.
 */
+ (void) saveObjects: (NSArray *) objects
      toFileWithName: (NSString *) fileName
             onQueue: (NSOperationQueue *) queue
   andDoThisWhenDone: (APCMedicationFileSaveCallback) completionBlock;

/**
 Subclasses:  Please use -init as your Designated Initializer.
 This super implementation does nothing.  However, your -init
 method will be called by initWithPlistEntry:, which is the
 point of this class.
 */
- (id) init NS_DESIGNATED_INITIALIZER;

- (id) initWithPlistEntry: (NSDictionary *) plistEntry;

/**
 Provided by subclasses to list the properties that should be archived.
 
 Subclasses:  please call -[super propertiesToSave] first, and append
 your properties to that list.
 */
- (NSArray *) namesOfPropertiesToSave;



@end
