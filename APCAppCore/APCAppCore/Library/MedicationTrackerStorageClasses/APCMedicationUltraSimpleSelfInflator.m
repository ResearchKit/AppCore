//
//  APCMedicationUltraSimpleSelfInflator.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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











