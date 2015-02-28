//
//  APCStudyOverviewCollectionViewCell.m
//  APCAppCore
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "APCStudyOverviewCollectionViewCell.h"

NSString *const kAPCStudyOverviewCollectionViewCellIdentifier = @"APCStudyOverviewCollectionViewCell";

@implementation APCStudyOverviewCollectionViewCell {
    CGFloat lastMultiplier;
}

-(void) performCustomInitialization {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFont) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

-(instancetype)init {
    if (self = [super init]) {
        [self performCustomInitialization];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self performCustomInitialization];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self performCustomInitialization];
    }
    return self;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // Disable user selection
    [webView  stringByEvaluatingJavaScriptFromString: @"document.documentElement.style.webkitUserSelect='none';"];
    lastMultiplier = 1.0;
    
    //Commenting the below method call as text resizing with system font size is not required.
    
    [self setFont];
    
    //Disable horizontal scrolling. Without delay we'll have scrollable webView in some cases
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webView.scrollView setContentSize: CGSizeMake(0, self.webView.scrollView.contentSize.height)];
    });
}

- (void)setFont {
    // This functionality needs to be properly hashed out,
    // therefore we are temporarily disabling it.
    //Scale text regarding Dynamic settings
//    NSString *javascriptFunc = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'", (int)([self preferredMultiplyValue] * 100)];
//    [self.webView stringByEvaluatingJavaScriptFromString: javascriptFunc];
//    lastMultiplier = [self preferredMultiplyValue];
}

- (CGFloat)preferredMultiplyValue {
    // choose the font multiplier
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    
    if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
        return 0.7;
    } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
        return 0.8;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
        return 0.9;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
        return 1.0;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
        return 1.1;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
        return 1.2;
    } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
        return 1.3;
    }
    return 1.0;
}

@end
