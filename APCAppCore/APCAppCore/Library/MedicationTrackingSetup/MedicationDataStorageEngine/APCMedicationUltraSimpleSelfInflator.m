//
//  APCMedicationUltraSimpleSelfInflator.m
//  AppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCMedicationUltraSimpleSelfInflator.h"

@implementation APCMedicationUltraSimpleSelfInflator

+ (NSURL *) urlForBundleFileWithName: (NSString *) name
{
    NSString *extension = [name pathExtension];
    NSString *baseName = [name substringToIndex: name.length - (extension.length + 1)];
    NSURL *url = [[NSBundle mainBundle] URLForResource: baseName withExtension: extension];
    return url;
}

+ (NSArray *) inflatedItemsFromPlistFileWithName: (NSString *) fileName
{
    NSURL *fileUrl = [self urlForBundleFileWithName: fileName];
    NSArray *rawData = [NSArray arrayWithContentsOfURL: fileUrl];

    NSMutableArray *inflatedObjects = [NSMutableArray new];

    for (id probablyDictionary in rawData)
    {
        id inflatedObject = [self inflateFromPlistEntry: probablyDictionary];

        [inflatedObjects addObject: inflatedObject];
    }

    return [NSArray arrayWithArray: inflatedObjects];
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
        // this -init method intentionally does nothing.
    }

    return self;
}

- (id) initWithPlistEntry: (NSDictionary *) plistEntry
{
    // Do some sort of safe, subclass-specific initialization.
    // Presumes (uh, mandates) that the subclasses use -init
    // as their Designated Initializer.
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

@end











