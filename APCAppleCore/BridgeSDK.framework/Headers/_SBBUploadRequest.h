//
//  SBBUploadRequest.h
//
//  $Id$
//
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBBUploadRequest.h instead.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
#import "SBBBridgeObject.h"

@protocol _SBBUploadRequest

@end

@interface _SBBUploadRequest : SBBBridgeObject

@property (nonatomic, strong) NSNumber* contentLength;

@property (nonatomic, assign) int64_t contentLengthValue;

@property (nonatomic, strong) NSString* contentMd5;

@property (nonatomic, strong) NSString* contentType;

@property (nonatomic, strong) NSString* name;

@end
