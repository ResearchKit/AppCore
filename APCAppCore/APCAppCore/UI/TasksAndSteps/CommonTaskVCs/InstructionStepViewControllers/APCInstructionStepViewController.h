// 
//  APCInstructionStepViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStepViewController.h"

@interface APCInstructionStepViewController : APCStepViewController

@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, strong) NSArray * headingsArray;
@property (nonatomic, strong) NSArray * messagesArray;

@property (weak, nonatomic) IBOutlet UIButton *gettingStartedButton;
@property (strong, nonatomic)        UIView   *accessoryContent;

@end
