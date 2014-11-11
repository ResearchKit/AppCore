//
//  APCInstructionStepViewController.h
//  APCAppleCore
//
//  Created by Dhanush Balachandran on 11/10/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCStepViewController.h"

@interface APCInstructionStepViewController : APCStepViewController

@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, strong) NSArray * headingsArray;
@property (nonatomic, strong) NSArray * messagesArray;

@property (weak, nonatomic) IBOutlet UIButton *gettingStartedButton;


@end
