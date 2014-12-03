//
//  APCParametersUserDefaultCell.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 9/23/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
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
