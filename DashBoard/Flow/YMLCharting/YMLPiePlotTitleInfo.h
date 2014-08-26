//
//  YMLPiePlotTitleInfo.h
//  Avero
//
//  Created by Mark Pospesel on 12/18/12.
//  Copyright (c) 2012 ymedialabs.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface YMLPiePlotTitleInfo : NSObject

@property (nonatomic, assign) BOOL wasRightSide;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGFloat alpha;
@property (nonatomic, strong) UIBezierPath *path;

@end
