//
//  APHNavigationFooter.h
//  mPowerSDK
//
//  Created by Shannon Young on 2/23/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APCNavigationFooterDelegate <NSObject>

- (void)goForward;

@end

@interface APCNavigationFooter : UIView

@property (weak, nonatomic) IBOutlet id <APCNavigationFooterDelegate> delegate;
@property (nonatomic) UIButton *continueButton;

@end
