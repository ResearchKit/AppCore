//
//  APCCriteriaCell.m
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCCriteriaCell.h"

@implementation APCCriteriaCell

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    UIColor *color = [UIColor colorWithWhite:0.8 alpha:0.5];
    
    self.containerView.layer.borderWidth = 1.0;
    self.containerView.layer.borderColor = color.CGColor;
    
    self.choice1.layer.borderWidth = 1.0;
    self.choice1.layer.borderColor = color.CGColor;
    
    self.choice2.layer.borderWidth = 1.0;
    self.choice2.layer.borderColor = color.CGColor;
    
    self.choice3.layer.borderWidth = 1.0;
    self.choice3.layer.borderColor = color.CGColor;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.choice1.frame = CGRectZero;
    self.choice2.frame = CGRectZero;
    self.choice3.frame = CGRectZero;
    
    CGRect bounds = self.containerView.bounds;
    
    CGFloat width = bounds.size.width;
    CGRect frame = CGRectMake(0, 0, width, bounds.size.height/2);
    self.textLabel.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(frame);
    
    switch (self.choices.count) {
        case 1:
            self.choice1.frame = frame;
            break;
            
        case 2:
            width = bounds.size.width/2;
            
            frame.size.width = width;
            self.choice1.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            frame.size.width += 1;
            self.choice2.frame = frame;
            break;
            
        case 3:
            width = bounds.size.width/3;
            
            frame.size.width = width;
            self.choice1.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            frame.size.width += 1;
            self.choice2.frame = frame;
            
            frame.origin.x = CGRectGetMaxX(frame) - 1;
            self.choice3.frame = frame;
            break;
            
        default:
            break;
    }
}

- (void) setChoices:(NSArray *)choices {
    if (_choices != choices) {
        _choices = choices;
        
        switch (self.choices.count) {
            case 1:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                break;
                
            case 2:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                [self.choice2 setTitle:self.choices[1] forState:UIControlStateNormal];
                break;
                
            case 3:
                [self.choice1 setTitle:self.choices[0] forState:UIControlStateNormal];
                [self.choice2 setTitle:self.choices[1] forState:UIControlStateNormal];
                [self.choice3 setTitle:self.choices[2] forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
    }
}

@end
