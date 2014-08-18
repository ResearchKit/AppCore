//
//  Parameters.m
//  Parameters
//
//  Created by Karthik Keyan on 8/14/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "Parameters.h"

// Notification constants
NSString *const ParametersValueChangeNotification   = @"com.apple.parameters.notification.valuechange";

// Private constants
NSString *const kParamentersFileName                = @"parameters.json";

@interface Parameters ()

@property (nonatomic, strong) NSMutableDictionary *values;

@end


@implementation Parameters

- (instancetype) init {
    self = [super init];
    if (self) {
        _values = [NSMutableDictionary new];
        
        [self loadValuesFromBundle];
    }
    return self;
}


#pragma mark - Private Methods

- (void) loadValuesFromBundle {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[self filePath]];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"File Parsing Error : %@", error);
    }
    else {
        self.values = [dict mutableCopy];
    }
}

- (NSString *) filePath {
    static NSString *filePath;
    
    if (!filePath) {
        NSArray *pathComponent = @[NSHomeDirectory(), @"Documents", kParamentersFileName];
        filePath = [NSString pathWithComponents:pathComponent];
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *fileNameAndExtension = [kParamentersFileName componentsSeparatedByString:@"."];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];
        
        NSError *error;
        if (![[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:filePath error:&error]) {
            NSLog(@"Copy File Error : %@", error);
        }
    }
    
    return filePath;
}


#pragma mark - Overrided Methods

- (id) valueForUndefinedKey:(NSString *)key {
    return [self.values valueForKey:key];
}

- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.values setValue:value forKey:key];
}


#pragma mark - Public Methods

- (NSArray *) allKeys {
    return [_values allKeys];
}

- (void) reset {
    NSError *error;
    if ([[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:&error]) {
        [self.values removeAllObjects];
        
        [self loadValuesFromBundle];
    }
    else {
        NSLog(@"Reset Error : %@", error);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ParametersValueChangeNotification object:nil];
}

- (BOOL) save {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.values options:0 error:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath]]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:&error]) {
            NSLog(@"Save Error : %@", error);
        }
    }
    
    BOOL isSaved = [data writeToFile:[self filePath] atomically:YES];
    
    if (isSaved) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ParametersValueChangeNotification object:nil];
    }
    
    return isSaved;
}

@end
