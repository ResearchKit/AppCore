//
//  APCPolygonView.h
//  APCAppCore
//
//  Created by Everest Liu on 2/27/16.
//  Copyright © 2016 Thread, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCPolygonView : UIView

@property (nonatomic) UIColor *tintColor;
@property (nonatomic) int numberOfSides;

- (instancetype)initWithFrame:(CGRect)frame andNumberOfSides:(int)sides;

@end
