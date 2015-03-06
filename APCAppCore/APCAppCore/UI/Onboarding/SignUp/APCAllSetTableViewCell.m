//
//  APCAllSetTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCAllSetTableViewCell.h"

@interface APCAllSetTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *originalTextBlock;
@property (weak, nonatomic) IBOutlet UILabel *additionalTextBlock;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;

@end

@implementation APCAllSetTableViewCell

- (void)setIcon:(UIImage *)icon
{
    _icon = icon;
    
    self.imageViewIcon.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setOriginalText:(NSString *)originalText
{
    _originalText = originalText;
    
    self.originalTextBlock.text  = originalText;
}

- (void)setAdditonalText:(NSString *)additonalText
{
    _additonalText = additonalText;
    
    self.additionalTextBlock.text = additonalText;
}

@end
