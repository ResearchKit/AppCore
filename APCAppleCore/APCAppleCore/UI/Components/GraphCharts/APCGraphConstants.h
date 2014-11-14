//
//  APCGraph.h
//  YMLCharts
//
//  Created by Ramsundar Shandilya on 10/6/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
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

static CGFloat const kAPCGraphTopPadding = 55.f;
static CGFloat const kXAxisHeight = 30.f;