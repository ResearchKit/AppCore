//
//  APCIntroductionViewController.h
//  APCAppleCore
//
//  Created by Henry McGilton on 10/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCIntroductionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *accessoryView;

- (void)setupWithInstructionalImages:(NSArray *)imageNames andParagraphs:(NSArray *)paragraphs;
- (void)setupWithInstructionalImages:(NSArray *)imageNames headlines: (NSArray*) headlines andParagraphs:(NSArray *)paragraphs;

@end
