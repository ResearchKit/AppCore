//
//  Parameters.h
//  Parameters
//
//  Created by Karthik Keyan on 8/14/14.
//  Copyright (c) 2014 Karthik Keyan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ParametersValueChangeNotification;

@class APCParameters;
@protocol APCParametersDelegate <NSObject>

- (void)parameters:(APCParameters *)parameters didFinishSaving:(id)item;
- (void)parameters:(APCParameters *)parameters didFailWithError:(NSError *)error;

@optional

- (void)parameters:(APCParameters *)parameters didFinishResetting:(id)item;

@end


@interface APCParameters : NSObject

@property (nonatomic, weak) id <APCParametersDelegate> delegate;

-(id)objectForKey:(NSString*)key;
-(void)setObject:(id)object forKey:(NSString*)key;
-(NSDictionary*)dictionary;

// Use [NSObject valueForKey:] to get value and [NSObject setValue:forKey:] to set values
- (NSArray *) allKeys;

// Clear all value and load values freshly from bundle
- (void) reset;

@end

/*
 
Parameters read in a data file pre-flight. Those parameters are used all over for tasks and schedule and possibly more. Parameters is an NSObject using KVC to store specific values, for example, tap interval should last for 20 seconds. Parameters should provide delegates to indicate state like error.

*/