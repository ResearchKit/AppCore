//
//  ViewController.m
//  Versioning
//
//  Created by Edward Cessna on 11/18/14.
//  Copyright (c) 2014 Edward Cessna. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.versionLabel.text = [self appVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)appVersion
{
    NSDictionary*   infoDict = [NSBundle mainBundle].infoDictionary;
    NSString*       version  = [NSString stringWithFormat:@"%@ (%@)",
                                [infoDict objectForKey:@"CFBundleShortVersionString"],
                                [infoDict objectForKey:@"CFBundleVersion"]];
    
    NSLog(@"Version: %@", version);
    
    return version;
}

@end
