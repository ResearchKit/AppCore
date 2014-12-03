//
//  APCWithdrawCompleteViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCWithdrawCompleteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
- (IBAction)withdrawComplete:(id)sender;
@end
