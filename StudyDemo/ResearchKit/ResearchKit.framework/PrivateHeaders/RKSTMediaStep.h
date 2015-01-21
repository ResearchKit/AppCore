//
//  RKSTMediaStep.h
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
RK_CLASS_AVAILABLE_IOS(8_3)
@interface RKSTMediaStep : RKSTStep

/**
 * @brief Prompt to display when requesting media capture
 */
@property (nonatomic, copy) NSString *request;

@property (nonatomic) RKMediaType mediaType;

@property (nonatomic) BOOL allowsEditing;

@end
