// 
//  APCResizeView.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, APCResizeViewType) {
    kAPCResizeViewTypeExpand,
    kAPCResizeViewTypeCollapse
};
@interface APCResizeView : UIView

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic) APCResizeViewType type;

- (CAShapeLayer *)shapeLayer;

@end
