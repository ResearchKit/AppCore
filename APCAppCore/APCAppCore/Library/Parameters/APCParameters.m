// 
//  APCParameters.m 
//  APCAppCore 
// 
// Copyright (c) 2015, Apple Inc. All rights reserved. 
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
// 
// 2.  Redistributions in binary form must reproduce the above copyright notice, 
// this list of conditions and the following disclaimer in the documentation and/or 
// other materials provided with the distribution. 
// 
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors 
// may be used to endorse or promote products derived from this software without 
// specific prior written permission. No license is granted to the trademarks of 
// the copyright holders even if such marks are included in this software. 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
// 
 
#import "APCParameters.h"
#import "APCConstants.h"
#import "APCParameters+Settings.h"


// Private constants
NSString *const kParamentersFileName                    = @"APCparameters.json";
NSString *const kHideConsentProperty                    = @"hideConsent";
NSString *const kBypassServerProperty                   = @"bypassServer";

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
    
    if ([self isNumber:value])
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
    
    if ([self isString:value])
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
    
    if (numberType == kCFNumberSInt64Type || numberType == kCFNumberSInt32Type)
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

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/

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
    if (!fileExists)
    {
        [self copyFileFromBundle];
    }
    [self setContentOfFileToDictionary];
}

- (void) copyFileFromBundle
{
    NSString *currentFileName = kParamentersFileName;
    currentFileName       = self.fileName;
    
    NSArray *fileNameAndExtension = [currentFileName componentsSeparatedByString:@"."];
    
    //This is used for unit testing
    //        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    //        NSString *bundlePath = [bundle pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:fileNameAndExtension[0] ofType:fileNameAndExtension[1]];
    
    BOOL           fileExists = [[NSFileManager defaultManager] fileExistsAtPath:bundlePath];
    if (fileExists) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:self.jsonPath error:&error]) {
            [self didFail:error];
        }
    }
    else
    {
        //If no file exists than we just create one.
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createFileAtPath:self.jsonPath contents:nil attributes:nil]) {
            
            [self didFail:error];
        }
    }
}

- (void)setContentOfFileToDictionary {
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:self.jsonPath];
    
    if (data) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if (!dict) {
            APCLogEvent(@"Could not parse JSON file at: %@", self.jsonPath);
            APCLogError2(error);
            
            [self didFail:error];
        } else {
            self.userDefaults = [dict mutableCopy];
        }
    } else {
        APCLogError(@"Contents of the file could not be loaded. The path that was provided is: %@", self.jsonPath);
    }
    
    [self addDefaultParametersIfNeeded];
}

- (void) addDefaultParametersIfNeeded
{
    if (self.userDefaults[kHideConsentProperty] == nil) {
        [self setBool:NO forKey:kHideConsentProperty];
    }
    if (self.userDefaults[kBypassServerProperty] == nil) {
        [self setBool:NO forKey:kBypassServerProperty];
    }
    if (self.userDefaults[kNumberOfMinutesForPasscodeKey] == nil) {
        [self setNumber:[APCParameters autoLockValues][0] forKey:kNumberOfMinutesForPasscodeKey];
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

/*********************************************************************************/
#pragma mark - Public Methods
/*********************************************************************************/
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

/*********************************************************************************/
#pragma mark - Properties
/*********************************************************************************/
- (BOOL)hideConsent
{
    return [self boolForKey:kHideConsentProperty];
}

- (void)setHideConsent:(BOOL)hideConsent
{
    [self setBool:hideConsent forKey:kHideConsentProperty];
}

- (BOOL)bypassServer
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kBypassServerProperty];
}

- (void)setBypassServer:(BOOL)bypassServer
{
    [[NSUserDefaults standardUserDefaults] setBool:bypassServer forKey:kBypassServerProperty];
}

- (BOOL)hideExampleConsent
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kExampleConsentKey];
}

- (void)setHideExampleConsent:(BOOL)hideExampleConsent
{
    [[NSUserDefaults standardUserDefaults] setBool:hideExampleConsent forKey:kExampleConsentKey];
}


/*********************************************************************************/
#pragma mark - Delegate Methods
/*********************************************************************************/

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
