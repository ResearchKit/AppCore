//
//  NSFileManager+Helper.h
//  APCAppCore
//
//  Created by Ron Conescu on 3/19/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Helper)

/**
 Creates a folder at the specified path, also creating all intermediate folders,
 using the folder permissions we need for this project.
 
 @return    YES if the folder was created, or if it already existed.
            NO if there was an error, in which case the errorToReturn
            *should* be filled in (if the underlying FileManager
            filled it in).
 
 @param     path    A location on disk.  A folder will be created here.
 
 @param     errorToReturn   Pass the address of an NSError variable to receive
                            a pointer to any errors we get from the file system.
                            Pass nil to suppress these errors.  If you suppress
                            this error, you can still check the return value
                            to see if the method worked.
 */
- (BOOL) createAPCFolderAtPath: (NSString *) path
                returningError: (NSError **) errorToReturn;

@end
