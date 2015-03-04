//
//  APCDashboardFoodInsightTableViewCell.m
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCDashboardFoodInsightTableViewCell.h"
#import "UIColor+APCAppearance.h"

@interface APCDashboardFoodInsightTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *foodType;
@property (nonatomic, weak) IBOutlet UILabel *foodSubCaption;
@property (nonatomic, weak) IBOutlet UILabel *frequency;
@property (nonatomic, weak) IBOutlet UIImageView *insightImageView;

@end

@implementation APCDashboardFoodInsightTableViewCell

- (void)sharedInit
{
    _foodName      = nil;
    _foodSubtitle  = nil;
    _foodFrequency = @(0);
    _insightImage  = nil;
    
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

- (void)setFoodName:(NSString *)foodName
{
    _foodName = foodName;
    
    self.foodType.text = foodName;
}

- (void)setFoodSubtitle:(NSString *)foodSubtitle
{
    _foodSubtitle = foodSubtitle;
    
    self.foodSubCaption.text = foodSubtitle;
}

- (void)setFoodFrequency:(NSNumber *)foodFrequency
{
    _foodFrequency = foodFrequency;
    
    self.frequency.text = [NSString stringWithFormat:@"%@x", foodFrequency];
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
    
    UIColor *borderColor = [UIColor lightGrayColor]; //[UIColor colorWithWhite:0.973 alpha:1.000];
        
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
