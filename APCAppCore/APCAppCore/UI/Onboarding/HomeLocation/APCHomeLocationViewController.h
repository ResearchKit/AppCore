//
//  APCHomeLocationViewController.h
//  APCAppCore
//
//  Created by Ramsundar Shandilya on 12/1/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APCSignUpProgressing.h"
#import "APCAddressTableViewCell.h"

@interface APCHomeLocationViewController : UIViewController <UISearchBarDelegate, APCSignUpProgressing, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;

- (IBAction)moreInfo:(id)sender;

- (IBAction)next:(id)sender;

@end
