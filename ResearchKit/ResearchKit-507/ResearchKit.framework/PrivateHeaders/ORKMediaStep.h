//
//  ORKMediaStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


typedef NS_ENUM(NSInteger, ORKMediaType) {
    ORKMediaTypeImage
};


/**
 * @brief A step for collecting media.
 */
ORK_CLASS_AVAILABLE
@interface ORKMediaStep : ORKStep

/**
 * @brief Prompt to display when requesting media capture
 */
@property (nonatomic, copy) NSString *request;

@property (nonatomic) ORKMediaType mediaType;

@property (nonatomic) BOOL allowsEditing;

@end
