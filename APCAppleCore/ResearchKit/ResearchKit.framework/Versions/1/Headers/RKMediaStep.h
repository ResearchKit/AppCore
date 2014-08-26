//
//  RKMediaStep.h
//  ResearchKit
//
//  Copyright (c) 2013-2014 Apple Inc. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>


typedef NS_ENUM(NSInteger, RKMediaType) {
    RKMediaTypeImage
};


/**
 * @brief A step for collecting media.
 */
@interface RKMediaStep : RKStep

/**
 * @brief Prompt to display when requesting media capture
 */
@property (nonatomic, copy) NSString *request;

@property (nonatomic) RKMediaType mediaType;

@property (nonatomic) BOOL allowsEditing;

@end
