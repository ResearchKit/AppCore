//
//  SBBUserProfile.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import "SBBBridgeObject.h"

@interface SBBUserProfile : SBBBridgeObject

@property (nonatomic, strong) NSString *firstName;

@property (nonatomic, strong) NSString *lastName;

@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) NSString *email;

@end
