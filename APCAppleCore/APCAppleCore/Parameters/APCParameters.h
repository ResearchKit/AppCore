//
//  APCParameters.h
//  APCAppleCore
//
//  Created by Justin Warmkessel on 8/14/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ParametersValueChangeNotification;

@protocol APCParametersDelegate;

@interface APCParameters : NSObject

@property (nonatomic, weak) id <APCParametersDelegate> delegate;

- (instancetype)                        init;
- (instancetype)                        initWithFileName:(NSString *)fileName;

- (id)                                  objectForKey:(NSString*)key;
- (NSNumber*)                           numberForKey:(NSString*)key;
- (NSString *)                          stringForKey:(NSString*)key;
- (BOOL)                                boolForKey:(NSString*)key;
- (NSInteger)                           integerForKey:(NSString*)key;
- (float)                               floatForKey:(NSString*)key;

- (void)setNumber:(NSNumber*)value      forKey:(NSString*)key;
- (void)setString:(NSString*)value      forKey:(NSString*)key;
- (void)setBool:(BOOL)value             forKey:(NSString*)key;
- (void)setInteger:(NSInteger)value     forKey:(NSString*)key;
- (void)setFloat:(float)value           forKey:(NSString*)key;

- (void)                                deleteValueforKey:(NSString *)key;

- (NSArray *)                           allKeys;
- (void)                                reset;

@end

//Protocol
/*********************************************************************************/
@protocol APCParametersDelegate <NSObject>

- (void)parameters:(APCParameters *)parameters didFailWithError:(NSError *)error;
- (void)parameters:(APCParameters *)parameters didFailWithValue:(id)value;
- (void)parameters:(APCParameters *)parameters didFailWithKey:(NSString *)key;

@optional

- (void)parameters:(APCParameters *)parameters didFinishSaving:(id)item;
- (void)parameters:(APCParameters *)parameters didFinishResetting:(id)item;

@end
/*********************************************************************************/