// 
//  APCDashboardInsightTableViewCell.m 
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
 
#import "APCDashboardInsightTableViewCell.h"
#import "APCInsightBarView.h"
#import "UIColor+APCAppearance.h"

@interface APCDashboardInsightTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *goodCaption;
@property (nonatomic, weak) IBOutlet UILabel *badCaption;
@property (nonatomic, weak) IBOutlet APCInsightBarView *goodBadBar;
@property (nonatomic, weak) IBOutlet UIImageView *insightImageView;

@end

@implementation APCDashboardInsightTableViewCell

- (void)sharedInit
{
    _goodInsightCaption = nil;
    _badInsightCaption  = nil;
    _goodInsightBar     = @(0);
    _badInsightBar      = @(0);
    _insightImage       = nil;
    _goodBadBar.goodDayValue = _goodInsightBar;
    _goodBadBar.badDayValue  = _badInsightBar;
    
    self.imageView.tintColor = [UIColor appPrimaryColor];
    self.layer.backgroundColor = [[UIColor whiteColor] CGColor];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self sharedInit];
    }
    
    return self;
}

- (void)setGoodInsightCaption:(NSString *)goodInsightCaption
{
    _goodInsightCaption = goodInsightCaption;
    
    self.goodCaption.text = goodInsightCaption;
}

- (void)setBadInsightCaption:(NSString *)badInsightCaption
{
    _badInsightCaption = badInsightCaption;
    
    self.badCaption.text = badInsightCaption;
}

- (void)setGoodInsightBar:(NSNumber *)goodInsightBar
{
    _goodInsightBar = goodInsightBar;
    
    self.goodBadBar.goodDayValue = goodInsightBar;
}

- (void)setBadInsightBar:(NSNumber *)badInsightBar
{
    _badInsightBar = badInsightBar;
    
    self.goodBadBar.badDayValue = badInsightBar;
}

- (void)setInsightImage:(UIImage *)insightImage
{
    _insightImage = insightImage;
    
    self.insightImageView.image = insightImage;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat borderWidth = 1.0;
    
    UIColor *borderColor = [UIColor lightGrayColor];
    
    // Bottom border
    CGContextSaveGState(context);
    CGContextSetLineCap(context, kCGLineCapSquare);
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, borderWidth);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Sidebar
    CGFloat sidebarWidth = 4.0;
    CGFloat sidbarHeight = rect.size.height;
    CGRect sidebar = CGRectMake(0, 0, sidebarWidth, sidbarHeight);
    
    UIColor *sidebarColor = self.tintColor;
    [sidebarColor setFill];
    UIRectFill(sidebar);
}

@end
