//
//  APCCriteriaCell.h
//  UI
//
//  Created by Karthik Keyan on 9/3/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APCCriteriaCell : UITableViewCell

@property (nonatomic, strong) NSArray *choices;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;

@property (nonatomic, weak) IBOutlet UIButton *choice1;

@property (nonatomic, weak) IBOutlet UIButton *choice2;

@property (nonatomic, weak) IBOutlet UIButton *choice3;

@end
