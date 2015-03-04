// 
//  APCParametersUserDefaultCell.m 
//  APCAppCore
//
//  Copyright © 2015 Apple, Inc. All rights reserved.
//
 
#import "APCParametersUserDefaultCell.h"

static CGFloat cellHeight = 114.0;

@implementation APCParametersUserDefaultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*********************************************************************************/
#pragma mark - Class Methods
/*********************************************************************************/

+ (float)heightOfCell {
    
    
    return cellHeight;
}

@end
