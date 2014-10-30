//
//  UIView+LoadXib.m
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/13/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "UIView+LoadXib.h"
#import "NSBundle+Helper.h"

static int const kViewTag = 5555;

@implementation UIView (LoadXib)

+ (id)loadInstanceFromNib
{
    UIView *result = nil;
    NSArray *elements = [[NSBundle appleCoreBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id anObject in elements) {
        if ([anObject isKindOfClass:[self class]]) {
            result = anObject;
            break;
        }
    }
    return result;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    if (self.tag == kViewTag) {
        //! placeholder
        UIView *realView = [[self class] loadInstanceFromNib];
        realView.frame = self.frame;
        realView.alpha = self.alpha;
        
        for (UIView *view in self.subviews) {
            [realView addSubview:view];
        }
        return realView;
    }
    
    return [super awakeAfterUsingCoder:aDecoder];
}

@end

