//
//  APCStudyDetailsViewController.h
//  APCAppleCore
//
//  Created by Ramsundar Shandilya on 10/28/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCTableViewItem.h"

@interface APCStudyDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) APCTableViewStudyDetailsItem *studyDetails;

@end
