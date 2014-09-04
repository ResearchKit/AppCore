//
//  Profile.h
//  Profile
//
//  Created by Karthik Keyan on 8/22/14.
//  Copyright (c) 2014 Y Media Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSUInteger, ProfileGender) {
    ProfileGenderMale = 0,
    ProfileGenderFemale,
    ProfileGenderOther
};

@interface Profile : NSObject

@property (nonatomic, copy) NSString *firstName;

@property (nonatomic, copy) NSString *lastName;

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *email;

@property (nonatomic, copy) NSString *password;

@property (nonatomic, strong) NSDate *dateOfBirth;

@property (nonatomic, copy) NSString *medicalCondition;

@property (nonatomic, copy) NSString *medication;

@property (nonatomic, copy) NSString *bloodType;

@property (nonatomic, strong) NSNumber *weight;

@property (nonatomic, strong) NSString *height;

@property (nonatomic, readwrite) ProfileGender gender;

@end


@interface Profile (DateOfBirth)

- (NSString *) dateOfBirthStringWithFormat:(NSString *)formate;

@end
