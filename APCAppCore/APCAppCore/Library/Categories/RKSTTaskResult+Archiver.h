//
//  RKSTTaskResult+Archiver.h
//  APCAppCore
//
//  Created by Dhanush Balachandran on 11/19/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <ResearchKit/ResearchKit.h>

@interface RKSTTaskResult (Archiver)

- (NSString *) archiveWithFilePath: (NSString*) filePath;

@end
