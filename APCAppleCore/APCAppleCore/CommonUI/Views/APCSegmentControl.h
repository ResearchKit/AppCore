//
//  APCSegmentControl.h
//  APCAppleCore
//
//  Created by Karthik Keyan on 9/11/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

@import UIKit;


#pragma mark - APCSegmentControlBorderLayer

@interface APCSegmentControlBorderLayer : CALayer

- (NSArray *) segmentLayers;

@end


#pragma mark - APCSegmentControl

@interface APCSegmentControl : UISegmentedControl

@property (nonatomic, strong) UIColor *segmentBorderColor;

@property (nonatomic, strong) APCSegmentControlBorderLayer *borderLayer;

- (void) setSegmentColor:(UIColor *)color atIndex:(NSUInteger)index;

@end
