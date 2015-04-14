// 
//  APCStudyOverviewCollectionViewCell.m 
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

- (BOOL)               webView: (UIWebView *) __unused webView
    shouldStartLoadWithRequest: (NSURLRequest*)request
                navigationType: (UIWebViewNavigationType)navigationType
{
    BOOL    shouldLoad = NO;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
    else
    {
        shouldLoad = YES;
    }
    
    return shouldLoad;
}

@end
