//
//  APCCriteriaCell.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"
#import "APCSegmentControl.h"
#import "UITableView+Appearance.h"

static CGFloat kAPCCriteriaCellContainerViewMargin  = 10;

@interface APCCriteriaCell ()

@property (nonatomic, strong) CALayer *separatorLayer;

@end

@implementation APCCriteriaCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [self addControls];
    [self applyStyle];
}

- (void) addControls {
    [self.containerView addSubview:self.valueTextField];
    [self.containerView addSubview:self.segmentControl];
    
    self.separatorLayer = [CALayer layer];
    [self.containerView.layer addSublayer:self.separatorLayer];
    
    self.valueTextField.hidden = YES;
    self.segmentControl.hidden = YES;
    self.captionLabel.hidden = YES;
}

- (void) applyStyle {
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.separatorLayer.backgroundColor = [UITableView controlsBorderColor].CGColor;
}

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.segmentControl.borderLayer.borderColor = [UIColor clearColor].CGColor;
    
    self.segmentControl.hidden = YES;
    self.valueTextField.hidden = YES;
    self.captionLabel.hidden = YES;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect containerFrame = CGRectInset(self.bounds, kAPCCriteriaCellContainerViewMargin, kAPCCriteriaCellContainerViewMargin);
    containerFrame.size.height += kAPCCriteriaCellContainerViewMargin;
    
    self.containerView.frame = containerFrame;
    
    CGRect containerBounds = self.containerView.bounds;
    
    CGRect textLabelFrame;
    CGRect remainingFrame;
    
    CGRectDivide(containerBounds, &textLabelFrame, &remainingFrame, containerBounds.size.height/2, CGRectMinYEdge);
    self.questionLabel.frame = textLabelFrame;
    
    CGRect separatorFrame = CGRectMake(0, textLabelFrame.size.height, textLabelFrame.size.width, 1);
    self.separatorLayer.frame = separatorFrame;
    
    if (!self.segmentControl.isHidden) {
        [self.segmentControl setFrame:remainingFrame];
    }
    
    remainingFrame = CGRectInset(remainingFrame, kAPCCriteriaCellContainerViewMargin, 0);
    
    if (!self.captionLabel.isHidden) {
        CGRect captionFrame;
        CGRectDivide(remainingFrame, &captionFrame, &remainingFrame, remainingFrame.size.width/2, CGRectMinXEdge);
        self.captionLabel.frame = captionFrame;
    }
    
    if (!self.valueTextField.isHidden) {
        self.valueTextField.frame = remainingFrame;
    }
}

@end
