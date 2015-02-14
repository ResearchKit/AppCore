//
//  ORKErrors.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ResearchKit/ORKDefines.h>


ORK_EXTERN NSString * const ORKErrorDomain ORK_AVAILABLE_DECL;
ORK_EXTERN NSString * const ORKInvalidArgumentException ORK_AVAILABLE_DECL;
ORK_EXTERN NSString * const ORKAbstractMethodException ORK_AVAILABLE_DECL;

typedef NS_ENUM(NSInteger, ORKErrorCode) {
    ORKErrorObjectNotFound         = -100101,
    ORKErrorInvalidObject          = -100104,
    ORKErrorException              = -100109,  // Exception caught during operation
    ORKErrorMultipleErrors         = -100112
} ORK_ENUM_AVAILABLE;


