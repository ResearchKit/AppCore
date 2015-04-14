// 
//  APCMedicationUltraSimpleSelfInflator.m 
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
 
#import "APCMedicationUltraSimpleSelfInflator.h"

@implementation APCMedicationUltraSimpleSelfInflator

+ (NSURL *) urlForBundleFileWithName: (NSString *) name
{
    NSString *extension = [name pathExtension];
    NSString *baseName = [name substringToIndex: name.length - (extension.length + 1)];
    NSURL *url = [[NSBundle bundleForClass: [self class]] URLForResource: baseName withExtension: extension];
    return url;
}

/**
 Attempts to load the stuff in the specified file as an 
 array of whatever subclass of mine is executing this code.
 */
+ (NSArray *) inflatedItemsFromPlistFileWithName: (NSString *) fileName
{
    NSURL *fileUrl = [self urlForBundleFileWithName: fileName];
    NSArray *rawData = [NSArray arrayWithContentsOfURL: fileUrl];

    NSMutableArray *inflatedObjects = [NSMutableArray new];

    for (id probablyDictionary in rawData)
    {
        if ([probablyDictionary isKindOfClass: [NSDictionary class]])
        {
            /*
             This calls the -inflate method below, which
             instantiates an object of the subclass of mine
             who's running this code.
             */
            id inflatedObject = [self inflateFromPlistEntry: probablyDictionary];

            [inflatedObjects addObject: inflatedObject];
        }
    }

    return [NSArray arrayWithArray: inflatedObjects];
}

+ (void) saveObjects: (NSArray *) objects
      toFileWithName: (NSString *) fileName
             onQueue: (NSOperationQueue *) queue
   andDoThisWhenDone: (APCMedicationFileSaveCallback) completionBlock
{
    NSDate *operationStartTime = [NSDate date];
    NSArray *arrayOfObjectsToSave = [NSArray arrayWithArray: objects];

    [queue addOperationWithBlock:^{

        NSMutableArray *arrayToSave = [NSMutableArray new];

        for (id item in arrayOfObjectsToSave)
        {
            NSMutableDictionary *theseProperties = [NSMutableDictionary new];

            NSArray *namesOfPropertiesToSave = [item namesOfPropertiesToSave];

            for (NSString *propertyName in namesOfPropertiesToSave)
            {
                id propertyValue = [item valueForKey: propertyName];

                if (propertyValue != nil)
                {
                    theseProperties [propertyName] = propertyValue;
                }
                else
                {
                    // Don't save it.
                }
            }

            [arrayToSave addObject: theseProperties];
        }

        NSArray *possibleDirectories = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = possibleDirectories [0];
        NSString *finalPath = [documentsDirectory stringByAppendingPathComponent: fileName];

        //
        // This is the file-write operation.
        //
        BOOL itWorked = [arrayToSave writeToFile: finalPath atomically: YES];

        //
        // Done!  We hope.
        //
        // As promised, call the caller back on this same queue he provided.
        //
        NSDate *operationEndTime = [NSDate date];
        NSTimeInterval operationElapsedTime = [operationEndTime timeIntervalSinceDate: operationStartTime];
        completionBlock (itWorked, operationElapsedTime);
    }];
}

+ (instancetype) inflateFromPlistEntry: (NSDictionary *) plistEntry
{
    id result = [[self alloc] initWithPlistEntry: plistEntry];

    return result;
}

- (id) init
{
    self = [super init];

    if (self)
    {
        // This means:  has not yet been retrieved from or saved to disk.  (I think.  Evolving.)
        self.uniqueId = nil;
    }

    return self;
}

- (id) initWithPlistEntry: (NSDictionary *) plistEntry
{
    /*
     Do some sort of safe, subclass-specific initialization.
     Presumes (uh, mandates) that the subclasses use -init
     as their Designated Initializer.
     */
    self = [self init];

    if (self)
    {
        for (NSString *key in plistEntry.allKeys)
        {
            id value = plistEntry [key];

            NSString *theSetMethod = [NSString stringWithFormat: @"set%@%@:",
                                      [key substringToIndex: 1].capitalizedString,
                                      [key substringFromIndex: 1]];

            if ([self respondsToSelector: NSSelectorFromString (theSetMethod)])
            {
                [self setValue: value forKey: key];
            }
        }
    }

    return self;
}

- (NSArray *) namesOfPropertiesToSave
{
    return @[ @"uniqueId" ];
}

@end











