// 
//  APCGraphConstants.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
typedef NS_ENUM(NSUInteger, APCGraphAnimationType) {
    kAPCGraphAnimationTypeNone,
    kAPCGraphAnimationTypeFade,
    kAPCGraphAnimationTypeGrow,
    kAPCGraphAnimationTypePop
};

typedef NS_ENUM(NSUInteger, APCGraphAxisType) {
    kAPCGraphAxisTypeX,
    kAPCGraphAxisTypeY
};

static CGFloat const kAPCGraphTopPadding = 0.f;
static CGFloat const kXAxisHeight = 30.f;
