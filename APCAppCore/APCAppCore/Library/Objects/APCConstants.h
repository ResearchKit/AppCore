// 
//  APCConstants.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, APCSignUpPermissionsType) {
    kSignUpPermissionsTypeNone = 0,
    kSignUpPermissionsTypeHealthKit,
    kSignUpPermissionsTypeLocation,
    kSignUpPermissionsTypeLocalNotifications,
    kSignUpPermissionsTypeCoremotion,
    kSignUpPermissionsTypeMicrophone,
    kSignUpPermissionsTypeCamera,
    kSignUpPermissionsTypePhotoLibrary
};

typedef NS_ENUM(NSUInteger, APCDashboardMessageType) {
    kAPCDashboardMessageTypeAlert,
    kAPCDashboardMessageTypeInsight,
};

typedef NS_ENUM(NSUInteger, APCDashboardGraphType) {
    kAPCDashboardGraphTypeLine,
    kAPCDashboardGraphTypeDiscrete,
};

FOUNDATION_EXPORT NSString *const APCUserSignedUpNotification;
FOUNDATION_EXPORT NSString *const APCUserSignedInNotification;
FOUNDATION_EXPORT NSString *const APCUserLogOutNotification;
FOUNDATION_EXPORT NSString *const APCUserWithdrawStudyNotification;
FOUNDATION_EXPORT NSString *const APCUserDidConsentNotification;

FOUNDATION_EXPORT NSString *const APCScheduleUpdatedNotification;
FOUNDATION_EXPORT NSString *const APCUpdateActivityNotification;

FOUNDATION_EXPORT NSString *const APCAppDidRegisterUserNotification;
FOUNDATION_EXPORT NSString *const APCAppDidFailToRegisterForRemoteNotification;

FOUNDATION_EXPORT NSString *const APCScoringHealthKitDataIsAvailableNotification;
FOUNDATION_EXPORT NSString *const APCTaskResultsProcessedNotification;

FOUNDATION_EXPORT NSString *const APCUpdateTasksReminderNotification;

FOUNDATION_EXPORT NSString *const APCConsentCompletedWithDisagreeNotification;

FOUNDATION_EXPORT NSString *const APCMotionHistoryReporterDoneNotification;

FOUNDATION_EXPORT NSString *const APCHealthKitObserverQueryUpdateForSampleTypeNotification;

FOUNDATION_EXPORT NSString *const kStudyIdentifierKey;
FOUNDATION_EXPORT NSString *const kAppPrefixKey;
FOUNDATION_EXPORT NSString *const kBridgeEnvironmentKey;
FOUNDATION_EXPORT NSString *const kDatabaseNameKey;
FOUNDATION_EXPORT NSString *const kTasksAndSchedulesJSONFileNameKey;
FOUNDATION_EXPORT NSString *const kConsentSectionFileNameKey;
FOUNDATION_EXPORT NSString *const kHKWritePermissionsKey;
FOUNDATION_EXPORT NSString *const kHKReadPermissionsKey;
FOUNDATION_EXPORT NSString *const kAppServicesListRequiredKey;
FOUNDATION_EXPORT NSString *const kAppServicesDescriptionsKey;
FOUNDATION_EXPORT NSString *const kAppProfileElementsListKey;
FOUNDATION_EXPORT NSString *const kVideoURLKey;
FOUNDATION_EXPORT NSString *const kTaskReminderStartupDefaultOnOffKey;
FOUNDATION_EXPORT NSString *const kTaskReminderStartupDefaultTimeKey;
FOUNDATION_EXPORT NSString *const kDBStatusVersionKey;

FOUNDATION_EXPORT NSString *const kAnalyticsOnOffKey;
FOUNDATION_EXPORT NSString *const kAnalyticsFlurryAPIKeyKey;	// Really. The NSDictionary key for something known as a "key."

FOUNDATION_EXPORT NSString *const kHKQuantityTypeKey;
FOUNDATION_EXPORT NSString *const kHKCategoryTypeKey;
FOUNDATION_EXPORT NSString *const kHKCharacteristicTypeKey;
FOUNDATION_EXPORT NSString *const kHKCorrelationTypeKey;
FOUNDATION_EXPORT NSString *const kHKWorkoutTypeKey;

FOUNDATION_EXPORT NSString * const kPasswordKey;
FOUNDATION_EXPORT NSString * const kNumberOfMinutesForPasscodeKey;

FOUNDATION_EXPORT NSInteger      const kAPCSigninErrorCode_NotSignedIn;
FOUNDATION_EXPORT NSUInteger     const kAPCSigninNumRetriesBeforePause;
FOUNDATION_EXPORT NSTimeInterval const kAPCSigninNumSecondsBetweenRetries;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulseFadeInTimeInSeconds;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulseFadeOutTimeInSeconds;
FOUNDATION_EXPORT NSTimeInterval const kAPCSignInButtonPulsePauseWhileVisibleTimeInSeconds;

FOUNDATION_EXPORT NSString *const kRegularFontNameKey;
FOUNDATION_EXPORT NSString *const kMediumFontNameKey;
FOUNDATION_EXPORT NSString *const kLightFontNameKey;

FOUNDATION_EXPORT NSString *const kHairlineEnDashJoinerKey;

FOUNDATION_EXPORT NSString *const kPrimaryAppColorKey;

FOUNDATION_EXPORT NSString *const kSecondaryColor1Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor2Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor3Key;
FOUNDATION_EXPORT NSString *const kSecondaryColor4Key;

FOUNDATION_EXPORT NSString *const kTertiaryColor1Key;
FOUNDATION_EXPORT NSString *const kTertiaryColor2Key;

FOUNDATION_EXPORT NSString *const kTertiaryGreenColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryBlueColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryRedColorKey ;
FOUNDATION_EXPORT NSString *const kTertiaryYellowColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryPurpleColorKey;
FOUNDATION_EXPORT NSString *const kTertiaryGrayColorKey;

FOUNDATION_EXPORT NSString *const kBorderLineColor;

FOUNDATION_EXPORT NSString *const kTasksReminderDefaultsOnOffKey;
FOUNDATION_EXPORT NSString *const kTasksReminderDefaultsTimeKey;

FOUNDATION_EXPORT NSString *const kScheduleOffsetTaskIdKey;
FOUNDATION_EXPORT NSString *const kScheduleOffsetOffsetKey;

FOUNDATION_EXPORT NSString *const kReviewConsentActionPDF;
FOUNDATION_EXPORT NSString *const kReviewConsentActionVideo;
FOUNDATION_EXPORT NSString *const kReviewConsentActionSlides;

FOUNDATION_EXPORT NSString *const kAllSetActivitiesTextOriginal;
FOUNDATION_EXPORT NSString *const kAllSetActivitiesTextAdditional;
FOUNDATION_EXPORT NSString *const kAllSetDashboardTextOriginal;
FOUNDATION_EXPORT NSString *const kAllSetDashboardTextAdditional;

FOUNDATION_EXPORT NSString *const kActivitiesSectionKeepGoing;
FOUNDATION_EXPORT NSString *const kActivitiesSectionYesterday;
FOUNDATION_EXPORT NSString *const kActivitiesSectionToday;



// ---------------------------------------------------------
#pragma mark - Events
// ---------------------------------------------------------

FOUNDATION_EXPORT NSString *const kAppStateChangedEvent;
FOUNDATION_EXPORT NSString *const kNetworkEvent;
FOUNDATION_EXPORT NSString *const kSchedulerEvent;
FOUNDATION_EXPORT NSString *const kTaskEvent;
FOUNDATION_EXPORT NSString *const kPageViewEvent;
FOUNDATION_EXPORT NSString *const kErrorEvent;
FOUNDATION_EXPORT NSString *const kPassiveCollectorEvent;



// ---------------------------------------------------------
#pragma mark - Known files, folders, extensions, and content types
// ---------------------------------------------------------

/*
 Folders that will appear in the user's Documents directory,
 or elsewhere that we might need to understand and inspect 'em.
 */

static NSString * const kAPCFolderName_ArchiveAndUpload_TopLevelFolder      = @"StuffBeingArchivedAndUploaded";
static NSString * const kAPCFolderName_ArchiveAndUpload_Archiving           = @"StuffBeingArchived";
static NSString * const kAPCFolderName_ArchiveAndUpload_Uploading           = @"StuffBeingUploaded";

static NSString * const kAPCFileName_EncryptedZipFile                       = @"encrypted.zip";
static NSString * const kAPCFileName_UnencryptedZipFile                     = @"unencrypted.zip";

static NSString * const kAPCFileExtension_JSON                              = @"json";
static NSString * const kAPCFileExtension_PrivateKey                        = @"pem";
static NSString * const kAPCFileExtension_CommaSeparatedValues              = @"csv";

static NSString * const kAPCContentType_JSON                                = @"application/json";



// ---------------------------------------------------------
#pragma mark - Known OperationQueue names
// ---------------------------------------------------------

static NSString * const kAPCOperationQueueName_ArchiveAndUpload_General                     = @"ArchiveAndUpload: Generic zip-and-upload queue";
static NSString * const kAPCOperationQueueName_ArchiveAndUpload_ModifyingListOfArchivers    = @"ArchiveAndUpload: Queue for adding and removing archivers to a global list";



// ---------------------------------------------------------
#pragma mark - Errors
// ---------------------------------------------------------

/*
 When we get enough examples, here, we'll make them consistent.
 (Still striving for consistency now, but this is also just a catchall.)
 */

typedef enum : NSInteger
{
    APCErrorCode_None                                       = 0,
    APCErrorCode_Undetermined                               = 1,

    APCErrorCode_CoreData_NoErrors                          = 100,
    APCErrorCode_CoreData_CantCreateDatabase,
    APCErrorCode_CoreData_CantOpenExistingDatabase,

    APCErrorCode_ArchiveAndUpload_NoErrors                  = 200,
    APCErrorCode_ArchiveAndUpload_CantCreateZipFile,
    APCErrorCode_ArchiveAndUpload_CantInsertZipEntry,
    APCErrorCode_ArchiveAndUpload_CantReadUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindDocumentsFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateArchiveFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateUploadFolder,
    APCErrorCode_ArchiveAndUpload_CantCreateWorkingDirectory,
    APCErrorCode_ArchiveAndUpload_DontHaveAnyZippedFiles,
    APCErrorCode_ArchiveAndUpload_CantCreateManifest,
    APCErrorCode_ArchiveAndUpload_CantSaveUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindUnencryptedFile,
    APCErrorCode_ArchiveAndUpload_CantEncryptFile,
    APCErrorCode_ArchiveAndUpload_CantSaveEncryptedFile,
    APCErrorCode_ArchiveAndUpload_CantFindEncryptedFile,
    APCErrorCode_ArchiveAndUpload_UploadFailed,
    APCErrorCode_ArchiveAndUpload_CantDeleteFileOrFolder,
}   APCErrorCode;

static NSString * const kAPCError_CoreData_Domain                                           = @"kAPCError_CoreData_Domain";

static NSString * const kAPCError_CoreData_CantCreateDatabase_Reason                        = @"Unable to Create Database";
static NSString * const kAPCError_CoreData_CantCreateDatabase_Suggestion                    = (@"We were unable to create a place to save your data. Please exit the app and try again. If the problem recurs, please uninstall the app and try once more.");

static NSString * const kAPCError_CoreData_CantOpenDatabase_Reason                          = @"Unable to Open Database";
static NSString * const kAPCError_CoreData_CantOpenDatabase_Suggestion                      = (@"Unable to open your existing data file. Please exit the app and try again. If the problem recurs, please uninstall and reinstall the app.");

static NSString * const kAPCError_ArchiveAndUpload_Domain                                   = @"kAPCError_ArchiveAndUpload_Domain";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateZipFile_Reason                 = @"Can't Create Archive";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateZipFile_Suggestion             = @"We couldn't create a .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantInsertZipEntry_Reason                = @"Can't Insert Zip Entry";
static NSString * const kAPCError_ArchiveAndUpload_CantInsertZipEntry_Suggestion            = @"We couldn't add one of the .zippable items to the .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Reason           = @"Can't Open Archive";
static NSString * const kAPCError_ArchiveAndUpload_CantReadUnencryptedFile_Suggestion       = @"Couldn't read the unencrypted .zip file we just tried to create.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Reason           = @"Can't find Documents folder";
static NSString * const kAPCError_ArchiveAndUpload_CantFindDocumentsFolder_Suggestion       = @"Couldn't find the user's 'documents' folder. This should never happen. Ahem.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Reason           = @"Can't find Documents folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateArchiveFolder_Suggestion       = @"Couldn't find the user's 'documents' folder. This should never happen. Ahem.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Reason            = @"Can't find Documents folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateUploadFolder_Suggestion        = @"Couldn't find the user's 'documents' folder. This should never happen. Ahem.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Reason        = @"Can't Create Working Folder";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateWorkingDirectory_Suggestion    = @"Couldn't create a folder in which to create a .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Reason            = @"Don't Have Files For Archive";
static NSString * const kAPCError_ArchiveAndUpload_DontHaveAnyZippedFiles_Suggestion        = @"Something went wrong. We don't seem to have any contents for this .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateManifest_Reason                = @"Can't Create Manifest";
static NSString * const kAPCError_ArchiveAndUpload_CantCreateManifest_Suggestion_Format     = @"Couldn't create the manifest file entry (%@.%@) in the .zip file.";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Reason           = @"Can't Save Unencrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveUnencryptedFile_Suggestion       = @"We couldn't save the unencrypted .zip file to disk.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Reason           = @"Can't Find Unencrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantFindUnencryptedFile_Suggestion       = @"We couldn't find the unencrypted .zip file on disk (even though we seem to have successfully saved it...?).";
static NSString * const kAPCError_ArchiveAndUpload_CantEncryptFile_Reason                   = @"Can't Encrypt Zip File";
static NSString * const kAPCError_ArchiveAndUpload_CantEncryptFile_Suggestion               = @"We couldn't encrypt the .zip file we need to upload.";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Reason             = @"Can't Save Encrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantSaveEncryptedFile_Suggestion         = @"We couldn't save the encrypted .zip file to disk.";
static NSString * const kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Reason             = @"Can't Find Encrypted File";
static NSString * const kAPCError_ArchiveAndUpload_CantFindEncryptedFile_Suggestion         = @"We couldn't find the encrypted .zip file on disk (even though we seem to have successfully encrypted it...?).";
static NSString * const kAPCError_ArchiveAndUpload_UploadFailed_Reason                      = @"Upload to Sage Failed";
static NSString * const kAPCError_ArchiveAndUpload_UploadFailed_Suggestion                  = @"We got an error when uploading to Sage.  See the nested error for details.";
static NSString * const kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Reason            = @"Can't Delete File/Folder";
static NSString * const kAPCError_ArchiveAndUpload_CantDeleteFileOrFolder_Suggestion        = @"We couldn't delete a file/folder creating during the archiving process. See attached path and nested error, if any, for details.";

@interface APCConstants : NSObject

@end












