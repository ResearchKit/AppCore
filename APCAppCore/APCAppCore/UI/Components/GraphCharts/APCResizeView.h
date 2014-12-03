//
//  APCResizeView.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 10/29/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
