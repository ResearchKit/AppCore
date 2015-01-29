// 
//  APCInstructionStepViewController.h 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCStepViewController.h"
@class APCButton;
@interface APCInstructionStepViewController : APCStepViewController

@property (nonatomic, strong) NSArray * imagesArray;
@property (nonatomic, strong) NSArray * headingsArray;
@property (nonatomic, strong) NSArray * messagesArray;

@property (weak, nonatomic) IBOutlet APCButton *gettingStartedButton;
@property (strong, nonatomic)        UIView   *accessoryContent;

@end
