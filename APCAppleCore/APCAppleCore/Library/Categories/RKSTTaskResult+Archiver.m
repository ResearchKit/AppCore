//
//  RKSTTaskResult+Archiver.m
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "RKSTTaskResult+Archiver.h"
#import "APCAppleCore.h"

NSString *const kCertFileName = @"rsacert";

@implementation RKSTTaskResult (Archiver)

- (NSString *) archiveWithFilePath: (NSString*) filePath
{
    //Archive
    RKSTDataArchive * archive = [[RKSTDataArchive alloc] initWithItemIdentifier:self.identifier
                                                                studyIdentifier:((APCAppDelegate*)[UIApplication sharedApplication].delegate).defaultInitializationOptions[kStudyIdentifierKey]
                                                                    taskRunUUID:self.taskRunUUID
                                                                  extraMetadata:nil
                                                                 fileProtection:RKFileProtectionCompleteUnlessOpen];
    
    [self.results enumerateObjectsUsingBlock:^(RKSTStepResult *stepResult, NSUInteger idx, BOOL *stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(RKSTResult *result, NSUInteger idx, BOOL *stop) {
            //Update date if needed
            if (!result.startDate) {
                result.startDate = stepResult.startDate;
                result.endDate = stepResult.endDate;
            }
            
            if ([result isKindOfClass:[RKSTDataResult class]])
            {
                
            }
            else if ([result isKindOfClass:[RKSTFileResult class]])
            {
                
            }
            else
            {
                NSError * archiveError;
                [result addToArchive:archive error:&archiveError];
                [archiveError handle];
            }
        }];
    }];
    
    NSError * archiveError;
    NSData * certFile = [self readPEM];
    NSData * data = (certFile) ? [archive archiveDataEncryptedWithIdentity:[self readPEM] error:&archiveError] : [archive archiveDataWithError:&archiveError];
    NSString * fileName = (certFile) ? @"encrypted.zip" : @"unencrypted.zip";
    NSString * retValue = [self writeData:data toFileName:fileName inPath:filePath] ? fileName : nil;
    return retValue;
}

- (BOOL) writeData: (NSData*) data toFileName: (NSString*) fileName inPath: (NSString*) filePath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&fileError];
        [fileError handle];
    }
    NSString * fullFilePath = [filePath stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        NSError * fileError;
        [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error:&fileError];
        [fileError handle];
    }
    
    BOOL retValue = NO;
    if ([data writeToFile: fullFilePath atomically:YES]) {
        retValue = YES;
    }
    else
    {
        retValue = NO;
        NSLog(@"Archive Not Written!!");
    }
    return retValue;
    
}

- (NSData*) readPEM
{
    NSString * path = [[NSBundle appleCoreBundle] pathForResource:kCertFileName ofType:@"pem"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    return data;
}

@end
