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
    [self setFont];
}

- (void)setFont {
    //Scale text regarding Dynamic settings
    NSString * javascriptFunc = [NSString stringWithFormat:@"function elementCurrentStyle(element, styleName){if (element.currentStyle){var i = 0, temp = \"\", changeCase = false;for (i = 0; i < styleName.length; i++)if (styleName[i] != '-'){temp += (changeCase ? styleName[i].toUpperCase() : styleName[i]);changeCase = false;} else {changeCase = true;}styleName = temp;return element.currentStyle[styleName];} else {return getComputedStyle(element, null).getPropertyValue(styleName);}};var all = document.getElementsByTagName(\"*\");for (var i=0; i < all.length; i++) {var element = all[i];var fontSize = elementCurrentStyle(element, \"font-size\");var fontSizeInt = parseInt(fontSize.replace(\"px\",\"\"));element.style.fontSize = (fontSizeInt*%f/%f) +\"px\";}", [self preferredMultiplyValue], lastMultiplier];
    [self.webView stringByEvaluatingJavaScriptFromString: javascriptFunc];
    lastMultiplier = [self preferredMultiplyValue];
    //Disable horizontal scrolling. Without delay we'll have scrollable webView in some cases
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webView.scrollView setContentSize: CGSizeMake(0, self.webView.scrollView.contentSize.height)];
    });
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
