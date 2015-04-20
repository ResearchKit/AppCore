//
//  HKWorkout+APCHelper.m
//  APCAppCore
//
//  Created by Justin Warmkessel on 4/20/15.
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//

#import "HKWorkout+APCHelper.h"

@implementation HKWorkout (APCHelper)

+ (NSString*)workoutActivityTypeStringRepresentation:(int)num
{
    NSDictionary* activityEvents =
    @{
      @(1)    : @"HKWorkoutActivityTypeAmericanFootball",
      @(2)    : @"HKWorkoutActivityTypeArchery",
      @(3)    : @"HKWorkoutActivityTypeAustralianFootball",
      @(4)    : @"HKWorkoutActivityTypeBadminton",
      @(5)    : @"HKWorkoutActivityTypeBaseball",
      @(6)    : @"HKWorkoutActivityTypeBasketball",
      @(7)    : @"HKWorkoutActivityTypeBowling",
      @(8)    : @"HKWorkoutActivityTypeBoxing",
      @(9)    : @"HKWorkoutActivityTypeClimbing",
      @(10)   : @"HKWorkoutActivityTypeCricket",
      @(11)   : @"HKWorkoutActivityTypeCrossTraining", // Any mix of cardio and/or strength and/or flexibility
      @(12)   : @"HKWorkoutActivityTypeCurling",
      @(13)   : @"HKWorkoutActivityTypeCycling",
      @(14)   : @"HKWorkoutActivityTypeDance",
      @(15)   : @"HKWorkoutActivityTypeDanceInspiredTraining", // Pilates, Barre, Feldenkrais, etc.
      @(16)   : @"HKWorkoutActivityTypeElliptical",
      @(17)   : @"HKWorkoutActivityTypeEquestrianSports", // Polo, Horse Racing, Horse Riding, etc.
      @(18)   : @"HKWorkoutActivityTypeFencing",
      @(19)   : @"HKWorkoutActivityTypeFishing",
      @(20)   : @"HKWorkoutActivityTypeFunctionalStrengthTraining", // Primarily free weights and/or body weight and/or accessories
      @(21)   : @"HKWorkoutActivityTypeGolf",
      @(22)   : @"HKWorkoutActivityTypeGymnastics",
      @(23)   : @"HKWorkoutActivityTypeHandball",
      @(24)   : @"HKWorkoutActivityTypeHiking",
      @(25)   : @"HKWorkoutActivityTypeHockey", // Ice Hockey, Field Hockey, etc.
      @(26)   : @"HKWorkoutActivityTypeHunting",
      @(27)   : @"HKWorkoutActivityTypeLacrosse",
      @(28)   : @"HKWorkoutActivityTypeMartialArts",
      @(29)   : @"HKWorkoutActivityTypeMindAndBody", // Tai chi, meditation, etc.
      @(30)   : @"HKWorkoutActivityTypeMixedMetabolicCardioTraining", // Any mix of cardio-focused exercises
      @(31)   : @"HKWorkoutActivityTypePaddleSports", // Canoeing, Kayaking, Outrigger, Stand Up Paddle Board, etc.
      @(32)   : @"HKWorkoutActivityTypePlay", // Dodge Ball, Hopscotch, Tetherball, Jungle Gym, etc.
      @(33)   : @"HKWorkoutActivityTypePreparationAndRecovery", // Foam rolling, stretching, etc.
      @(34)   : @"HKWorkoutActivityTypeRacquetball",
      @(35)   : @"HKWorkoutActivityTypeRowing",
      @(36)   : @"HKWorkoutActivityTypeRugby",
      @(37)   : @"HKWorkoutActivityTypeRunning",
      @(38)   : @"HKWorkoutActivityTypeSailing",
      @(39)   : @"HKWorkoutActivityTypeSkatingSports", // Ice Skating, Speed Skating, Inline Skating, Skateboarding, etc.
      @(40)   : @"HKWorkoutActivityTypeSnowSports", // Skiing, Snowboarding, Cross-Country Skiing, etc.
      @(41)   : @"HKWorkoutActivityTypeSoccer",
      @(42)   : @"HKWorkoutActivityTypeSoftball",
      @(43)   : @"HKWorkoutActivityTypeSquash",
      @(44)   : @"HKWorkoutActivityTypeStairClimbing",
      @(45)   : @"HKWorkoutActivityTypeSurfingSports", // Traditional Surfing, Kite Surfing, Wind Surfing, etc.
      @(46)   : @"HKWorkoutActivityTypeSwimming",
      @(47)   : @"HKWorkoutActivityTypeTableTennis",
      @(48)   : @"HKWorkoutActivityTypeTennis",
      @(49)   : @"HKWorkoutActivityTypeTrackAndField", // Shot Put, Javelin, Pole Vaulting, etc.
      @(50)   : @"HKWorkoutActivityTypeTraditionalStrengthTraining", // Primarily machines and/or free weights
      @(51)   : @"HKWorkoutActivityTypeVolleyball",
      @(52)   : @"HKWorkoutActivityTypeWalking",
      @(53)   : @"HKWorkoutActivityTypeWaterFitness",
      @(54)   : @"HKWorkoutActivityTypeWaterPolo",
      @(55)   : @"HKWorkoutActivityTypeWaterSports", // Water Skiing, Wake Boarding, etc.
      @(56)   : @"HKWorkoutActivityTypeWrestling",
      @(57)   : @"HKWorkoutActivityTypeYoga",
      @(3000) : @"HKWorkoutActivityTypeOther"
      };
    
    return [activityEvents objectForKey:@(num)];
}

@end
