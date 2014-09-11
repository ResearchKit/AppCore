//
//  Parameters.m
//  Parameters
//
//  Created by Karthik Keyan on 8/14/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import "APCParameters.h"


// Notification constants
NSString *const ParametersValueChangeNotification   = @"com.apple.parameters.notification.valuechange";

// Private constants
NSString *const kParamentersFileName                = @"APCparameters.plist";

@interface APCParameters ()

@property  (nonatomic, strong)  NSMutableDictionary     *plistDict;
@property  (nonatomic, strong)  NSString                *plistPath;

@end


@implementation APCParameters


- (instancetype) init {
    self = [super init];
    if (self) {
        _plistDict = [NSMutableDictionary new];
        
        [self loadValuesFromBundle];
    }
    return self;
}


#pragma mark - Private Methods


- (void) loadValuesFromBundle {
    
    //Load files from bundle if .plist file doesn't exist
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    self.plistPath = [documentsPath stringByAppendingPathComponent:kParamentersFileName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.plistPath];
    
    if (!fileExists) {
        NSArray *fileNameAndExtension = [kParamentersFileName componentsSeparatedByString:@"."];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];
        
        NSError *error;
        if (![[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:self.plistPath error:&error]) {
            NSLog(@"Copy File Error : %@", error);
            
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.plistPath];
            
            NSError *error;
            self.plistDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (![self.plistDict writeToFile:self.plistPath atomically: YES]) {
                NSLog(@"FAILED TO STORE PLISTDICT - %@", self.plistPath);
                return;
            }
        }
    }
}


-(id)objectForKey:(NSString*)key {

    id value = [self.plistDict objectForKey:key];
    
    if ([self isNumber:(NSString *)value]) {

        NSNumber *number = [[NSNumber alloc] init];

        number = @([self.plistDict[key] floatValue]);
    }
        
    return value;
}


-(NSDictionary*)dictionary {
    return self.plistDict;
}


-(void)setObject:(id)object forKey:(NSString*)key {

    if (object != nil) {
        
        [self.plistDict setValue:object forKey:key];
        
    } else {
        
        [self.plistDict removeObjectForKey:key];
        
    }
    
    if (![self.plistDict writeToFile:self.plistPath atomically: YES]) {
        NSLog(@"FAILED TO STORE PLISTDICT - %@", self.plistPath);
        return;
    }
}


- (void) removeValueforKey:(NSString *)key {
    [self.plistDict removeObjectForKey:key];

    if (![self.plistDict writeToFile:self.plistPath atomically: YES]) {
        NSLog(@"FAILED TO STORE PLISTDICT - %@", self.plistPath);
        return;
    }
}


- (BOOL) isNumber:(NSString *)string {
    BOOL isNumber = NO;
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location == NSNotFound)
    {
        NSLog(@"Supposedly valid");
        isNumber = YES;
    } else {
        NSLog(@"Not valid");
    }
    
    return isNumber;
}


#pragma mark - Overrided Methods

- (id) valueForUndefinedKey:(NSString *)key {
    return [self.plistDict valueForKey:key];
}


- (void) setValue:(id)value forUndefinedKey:(NSString *)key {
    [self.plistDict setValue:value forKey:key];
}


#pragma mark - Public Methods

- (NSArray *) allKeys {
    return [self.plistDict allKeys];
}


- (void) reset {
    //Reset takes the data from document and sets values to that.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kParamentersFileName];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        [self loadValuesFromBundle];
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ParametersValueChangeNotification object:nil];
}


#pragma mark - Delegate Methods

- (void)didFail:(NSError *)error {

    if ( [self.delegate respondsToSelector:@selector(parameters:didFailWithError:)] ) {

        [self.delegate parameters:self didFailWithError:error];
    }
}

- (void)didSave:(id)object {

    if ( [self.delegate respondsToSelector:@selector(parameters:didFinishSaving:)] ) {
        
        [self.delegate parameters:self didFinishSaving:object];
    }
}

- (void)didReset:(id)object {
    
    if ( [self.delegate respondsToSelector:@selector(parameters:didFinishResetting:)] ) {
        
        [self.delegate parameters:self didFinishResetting:object];
    }
}
@end
