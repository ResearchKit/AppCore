// 
//  APCIntroductionViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>

@interface APCIntroductionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *accessoryView;

- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs;
- (void)setupWithInstructionalImages:(NSArray *)imageNames headlines: (NSArray*) headlines andParagraphs:(NSArray *)paragraphs;

@end
