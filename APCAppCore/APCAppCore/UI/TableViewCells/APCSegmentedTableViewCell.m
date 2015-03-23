// 
//  APCSegmentedTableViewCell.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCSegmentedTableViewCell.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"

NSString * const kAPCSegmentedTableViewCellIdentifier = @"APCSegmentedTableViewCell";

@interface APCSegmentedTableViewCell ()<APCSegmentedButtonDelegate>

@end

@implementation APCSegmentedTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.segmentedButton = [[APCSegmentedButton alloc] initWithButtons:@[self.maleButton, self.femaleButton] normalColor:[UIColor appSecondaryColor3] highlightColor:[UIColor appSecondaryColor1]];
    [self.segmentedButton setSelectedIndex:0];
    self.segmentedButton.delegate = self;
    
    [self setupAppearance];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupAppearance
{
    [self.maleButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
    [self.femaleButton.titleLabel setFont:[UIFont appRegularFontWithSize:16.0]];
}

- (void) segmentedButtonPressed: (UIButton*) __unused  button
				  selectedIndex: (NSInteger) selectedIndex
{
    self.selectedSegmentIndex = selectedIndex;
    
    if ([self.delegate respondsToSelector:@selector(segmentedTableViewCell:didSelectSegmentAtIndex:)]) {
        [self.delegate segmentedTableViewCell:self didSelectSegmentAtIndex:self.selectedSegmentIndex];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex
{
    _selectedSegmentIndex = selectedSegmentIndex;
    
    [self.segmentedButton setSelectedIndex:selectedSegmentIndex];
}

@end
