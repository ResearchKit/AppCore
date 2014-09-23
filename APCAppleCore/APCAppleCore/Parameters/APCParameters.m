//
//  APCParameters.m
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import "APCParameters.h"


// Private constants
NSString *const kParamentersFileName                    = @"APCparameters.json";


@interface APCParameters ()

@property  (nonatomic, strong)  NSMutableDictionary     *userDefaults;
@property  (nonatomic, strong)  NSString                *jsonPath;
@property  (nonatomic, strong)  NSString                *fileName;

@end


@implementation APCParameters

- (instancetype)init
{
    self = [self initWithFileName:kParamentersFileName];
    
    return self;
}

- (instancetype) initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        _userDefaults = [NSMutableDictionary new];
        _fileName = fileName;
        
        /* This should only be called inside the init */
        [self loadValuesFromBundle];
    }
    return self;
}

- (id)objectForKey:(NSString *)key {
    return [self.userDefaults objectForKey:key];
}

- (NSNumber*)numberForKey:(NSString*)key
{
    NSNumber*   number = nil;
    id          value = [self.userDefaults objectForKey:key];
    
    if ([self isNumber:value] == YES)
    {
        number = (NSNumber*)value;
    }
    else
    {
        [self didFailWithValue:value];
    }
    
    return number;
}


- (NSString *)stringForKey:(NSString*)key
{
    NSString*   str = nil;
    id          value = [self.userDefaults objectForKey:key];
    
    if ([self isString:value] == YES)
    {
        str = (NSString*)value;
    }
    else
    {
        [self didFailWithKey:value];
    }
    
    return str;
}


- (BOOL)boolForKey:(NSString *)key
{
    NSNumber*   number = [self numberForKey:key];
    BOOL        boolean = NO;
    
    if (number == (void*)kCFBooleanFalse || number == (void*)kCFBooleanTrue)
    {
        boolean = number.boolValue;
    }
    else
    {
        [self didFailWithKey:key];
    }
    
    return boolean;
}


- (NSInteger)integerForKey:(NSString *)key
{
    NSNumber*   number = [self numberForKey:key];
    NSInteger   integer = 0;
    
    CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
    
    if (numberType == kCFNumberSInt64Type)
    {
        integer = number.integerValue;
    }
    else
    {
        [self didFailWithKey:key];
    }
    
    return integer;
}

- (float)floatForKey:(NSString *)key
{
    NSNumber*   number = [self numberForKey:key];
    float       aFloat = 0.0;
    
    CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
    
    if (numberType == kCFNumberFloat64Type)
    {
        aFloat = number.floatValue;
    }
    else
    {
        [self didFailWithKey:key];
    }
    
    return aFloat;
}


- (void)setNumber:(NSNumber*)value  forKey:(NSString*)key
{
    NSParameterAssert(value != nil);
    
    [self.userDefaults setObject:value forKey:key];
    
    [self saveToFile];
}


- (void)setString:(NSString*)value  forKey:(NSString*)key
{
    NSParameterAssert(value != nil);
    
    [self.userDefaults setObject:value forKey:key];
    
    [self saveToFile];
}


- (void)setBool:(BOOL)value         forKey:(NSString*)key
{
    NSNumber*   boolValue = [NSNumber numberWithBool:value];
    [self setNumber:boolValue forKey:key];
}


- (void)setInteger:(NSInteger)value forKey:(NSString *)key
{
    NSNumber*   intNumber = [NSNumber numberWithInteger:value];
    [self setNumber:intNumber forKey:key];
}


- (void)setFloat:(float)value     forKey:(NSString *)key {
    NSNumber*   intNumber = [NSNumber numberWithFloat:value];
    [self setNumber:intNumber forKey:key];
}


- (void)deleteValueforKey:(NSString *)key
{
    [self.userDefaults removeObjectForKey:key];
    
    [self saveToFile];
}


#pragma mark - Private Methods

- (void)saveToFile {
    NSError *error;
    
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:self.jsonPath append:NO];
    
    [outputStream open];
    
    if (![NSJSONSerialization writeJSONObject:self.userDefaults toStream:outputStream options:0 error:&error]) {
        [self didFail:error];
    } else {
        [self didSave:self.userDefaults];
    }
    
    [outputStream close];
}


/* This should only be called at initWithFileName */
- (void) loadValuesFromBundle {
    
    NSString*   documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    self.jsonPath             = [documentsPath stringByAppendingPathComponent:kParamentersFileName];
    BOOL           fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.jsonPath];
    
    NSString *currentFileName = kParamentersFileName;
    
    if (!fileExists) {
        currentFileName       = self.fileName;
        
        NSArray *fileNameAndExtension = [currentFileName componentsSeparatedByString:@"."];
        
        //This is used for unit testing
//        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//        NSString *bundlePath = [bundle pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];

        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];
        
        NSError *error;
        if (![[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:self.jsonPath error:&error]) {
            
            [self didFail:error];
        } else {
            
            [self setContentOfFileToDictionary];
        }
    } else {
        
        [self setContentOfFileToDictionary];
    }
}

- (void)setContentOfFileToDictionary {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.jsonPath];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (error) {
        NSLog(@"File Parsing Error : %@", error);
        [self didFail:error];
    }
    else {
        self.userDefaults = [dict mutableCopy];
    }
}


- (BOOL) isString:(id)value {
    BOOL isString = [value isKindOfClass:[NSString class]];

    return isString;
}


- (BOOL) isNumber:(id)value {
    BOOL isNumber = [value isKindOfClass:[NSNumber class]];
    
    return isNumber;
}


#pragma mark - Public Methods

- (NSArray *) allKeys {
    return [self.userDefaults allKeys];
}


- (void) reset {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kParamentersFileName];
    
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
        [self didFail:error];
        
    } else {
        [self didReset:self.userDefaults];
        [self loadValuesFromBundle];

    }
}


#pragma mark - Delegate Methods

- (void) didFail:(NSError *)error {

    if ( [self.delegate respondsToSelector:@selector(parameters:didFailWithError:)] ) {

        [self.delegate parameters:self didFailWithError:error];
    }
}


- (void) didFailWithValue:(id)value {
    
    if ( [self.delegate respondsToSelector:@selector(parameters:didFailWithValue:)] ) {
        
        [self.delegate parameters:self didFailWithValue:value];
    }
}


- (void) didFailWithKey:(NSString *)key {
    
    if ( [self.delegate respondsToSelector:@selector(parameters:didFailWithKey:)] ) {
        
        [self.delegate parameters:self didFailWithKey:key];
    }
}


- (void) didSave:(id)object {

    if ( [self.delegate respondsToSelector:@selector(parameters:didFinishSaving:)] ) {
        
        [self.delegate parameters:self didFinishSaving:object];
    }
}


- (void) didReset:(id)object {
    
    if ( [self.delegate respondsToSelector:@selector(parameters:didFinishResetting:)] ) {
        
        [self.delegate parameters:self didFinishResetting:object];
    }
}
@end
