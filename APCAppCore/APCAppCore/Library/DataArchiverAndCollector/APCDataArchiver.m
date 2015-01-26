//
//  APCDataArchiver.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDataArchiver.h"
#import "APCAppCore.h"
#import "zipzap.h"
#import <objc/runtime.h>

@interface APCDataArchiver ()

@property (nonatomic, strong) ZZArchive * zipArchive;
@property (nonatomic, strong) NSMutableDictionary * infoDict;
@property (nonatomic, strong) NSString * tempOutputDirectory;
@property (nonatomic, readonly) NSString * tempUnencryptedZipFilePath;
@property (nonatomic, readonly) NSString * tempEncryptedZipFilePath;

@end

@implementation APCDataArchiver

- (instancetype)init {
    self = [super init];
    if (self) {
        self.infoDict = [NSMutableDictionary dictionary];
        self.tempOutputDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        NSError * error;
        self.zipArchive = [[ZZArchive alloc] initWithURL:[NSURL fileURLWithPath:[self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"]]
                                                 options:@{ZZOpenOptionsCreateIfMissingKey : @YES}
                                                   error:&error];
        APCLogError2(error);
        
        self.preserveUnencryptedFile = NO;
    }
    return self;
}

-(NSString *)tempUnencryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"unencrypted.zip"];
}
-(NSString *)tempEncryptedZipFilePath {
    return [self.tempOutputDirectory stringByAppendingPathComponent:@"encrypted.zip"];
}

- (void)setTempOutputDirectory:(NSString *)tempOutputDirectory {
    _tempOutputDirectory = tempOutputDirectory;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempOutputDirectory]) {
        NSError * fileError;
        [[NSFileManager defaultManager] createDirectoryAtPath:tempOutputDirectory withIntermediateDirectories:YES attributes:nil error:&fileError];
        APCLogError2 (fileError);
    }
}

/*********************************************************************************/
#pragma mark - Task Results
/*********************************************************************************/
//Convenience Initializer
- (instancetype) initWithTaskResult: (RKSTTaskResult*) taskResult {
    return [self initWithResults:taskResult.results itemIdentifier:taskResult.identifier runUUID:taskResult.taskRunUUID];
}

- (instancetype)initWithResults: (NSArray*) results itemIdentifier: (NSString*) itemIdentifier runUUID: (NSUUID*) runUUID {
    self = [self init];
    if (self) {
        [self processResults:results];
    }
    return self;
}

- (void) processResults: (NSArray*) results {
    
    [results enumerateObjectsUsingBlock:^(RKSTStepResult *stepResult, NSUInteger idx, BOOL *stop) {
        [stepResult.results enumerateObjectsUsingBlock:^(RKSTResult *result, NSUInteger idx, BOOL *stop) {
            //Update date if needed
            if (!result.startDate) {
                result.startDate = stepResult.startDate;
                result.endDate = stepResult.endDate;
            }
            
            if ([result isKindOfClass:[APCDataResult class]])
            {
                APCDataResult * dataResult = (APCDataResult*) result;
                [self addDataToArchive:dataResult.data fileName:[dataResult.identifier stringByAppendingString:@"_data"] contentType:@"data" timeStamp:dataResult.endDate metadata:nil];
            }
            else if ([result isKindOfClass:[RKSTFileResult class]])
            {
                RKSTFileResult * fileResult = (RKSTFileResult*) result;
                [self addFileToArchive:fileResult.fileURL contentType:@"data" metadata:nil];
            }
            else
            {
                [self addResultToArchive:result];
            }
        }];
    }];
    
    [self finalizeZipFile];
}

- (void) addDataToArchive: (NSData*) data fileName: (NSString*) string contentType:(NSString*) contentType timeStamp: (NSDate*) date metadata: (NSDictionary*) metadata {
    
}

- (void) addFileToArchive: (NSURL*) fileURL contentType: (NSString*) contentType metadata: (NSDictionary*) metadata {
    
}

- (void) addResultToArchive: (RKSTResult*) result {
    NSArray * properties = [APCDataArchiver classPropsFor:result.class];
    NSDictionary * dictionary = [result dictionaryWithValuesForKeys:properties];
    APCLogDebug(@"%@", dictionary);
}

- (void) finalizeZipFile {
    
}

/*********************************************************************************/
#pragma mark - Write Output File
/*********************************************************************************/
- (NSString*)writeToOutputDirectory:(NSString *)outputDirectory {
    
    NSAssert([[NSFileManager defaultManager] fileExistsAtPath:outputDirectory], @"Output Directory does not exist");
    
    [self encryptZipFile];
//
    NSError * moveError;
    [[NSFileManager defaultManager] moveItemAtPath:self.tempEncryptedZipFilePath toPath:outputDirectory error:&moveError];
    APCLogError2(moveError);
    
    if (self.preserveUnencryptedFile) {
        [[NSFileManager defaultManager] moveItemAtPath:self.tempUnencryptedZipFilePath toPath:outputDirectory error:&moveError];
        APCLogError2(moveError);
    }
    else {
        [[NSFileManager defaultManager] removeItemAtPath:self.tempUnencryptedZipFilePath error:&moveError];
        APCLogError2(moveError);
    }
    return @"unencrypted.zip";
}

- (void) encryptZipFile {
    NSData * unencryptedZipData = [NSData dataWithContentsOfFile:self.tempUnencryptedZipFilePath];
    
    NSError * encryptionError;
    NSData * encryptedZipData = RKSTCryptographicMessageSyntaxEnvelopedData(unencryptedZipData, [self readPEM], RKEncryptionAlgorithmAES128CBC, &encryptionError);
    APCLogError2(encryptionError);
    
    NSError * fileWriteError;
    [encryptedZipData writeToFile:self.tempEncryptedZipFilePath options:NSDataWritingAtomic error:&fileWriteError];
    APCLogError2(fileWriteError);
}

/*********************************************************************************/
#pragma mark - Helpers
/*********************************************************************************/
- (NSData*) readPEM
{
    APCAppDelegate * appDelegate = (APCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSString * path = [[NSBundle mainBundle] pathForResource:appDelegate.certificateFileName ofType:@"pem"];
    NSData * data = [NSData dataWithContentsOfFile:path];
    NSAssert(data != nil, @"Please add PEM file");
    return data;
}

+ (NSArray *)classPropsFor:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            [results addObject:propertyName];
        }
    }
    free(properties);
    
    return [NSArray arrayWithArray:results];
}

@end
