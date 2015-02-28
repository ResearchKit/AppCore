//
//  APCDashboardInsightTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
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
