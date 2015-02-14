//
//  RKSTErrors.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/RKSTDefines.h>


RK_EXTERN NSString * const RKErrorDomain RKST_AVAILABLE_IOS(8_3);
RK_EXTERN NSString * const RKInvalidArgumentException RKST_AVAILABLE_IOS(8_3);
RK_EXTERN NSString * const RKAbstractMethodException RKST_AVAILABLE_IOS(8_3);

typedef NS_ENUM(NSInteger, RKErrorCode) {
    RKNoError = 0,
    RKErrorUnsupportedFeature     = -100100,
    RKErrorObjectNotFound         = -100101,
    RKErrorDuplicateId            = -100102,
    RKErrorInitFailed             = -100103,
    RKErrorInvalidObject          = -100104,
    RKErrorNotLoaded              = -100105,
    RKErrorCancelled              = -100106,
    RKErrorTimeout                = -100107,
    RKErrorQueueFull              = -100108,
    RKErrorException              = -100109,  // Exception caught during operation
    RKErrorArchiveFailed          = -100110,   // could not create archive
    RKErrorBackground             = -100111,
    RKErrorMultipleErrors         = -100112,
    RKErrorUserDeclinedSigning    = -100113
} RK_ENUM_AVAILABLE_IOS(8_3);


