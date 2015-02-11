//
//  APCStudyOverviewCollectionViewCell.m
//  APCAppCore
//
//  Created by Dzianis Asanovich on 2/10/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "APCStudyOverviewCollectionViewCell.h"

@implementation APCStudyOverviewCollectionViewCell

-(void) performCustomInitialization {
    self.webView.delegate = self;
    [self.webView setDataDetectorTypes:UIDataDetectorTypeAll];
    self.webView.scalesPageToFit = YES;
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
    [webView.scrollView setContentSize: CGSizeMake(webView.bounds.size.width, webView.scrollView.contentSize.height)];
}


@end
