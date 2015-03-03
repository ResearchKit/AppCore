//
//  SBBBridgeAPIManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 10/10/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

@protocol SBBAuthManagerProtocol;
@protocol SBBNetworkManagerProtocol;
@protocol SBBObjectManagerProtocol;

/*!
 This is the "base protocol" for Bridge API Managers.
 */
@protocol SBBBridgeAPIManagerProtocol <NSObject>

@end

/*!
 This is an abstract base class for SBBComponents that implement parts of the Bridge REST API.
 */
@interface SBBBridgeAPIManager : NSObject<SBBBridgeAPIManagerProtocol>

@property (nonatomic, strong, readonly) id<SBBNetworkManagerProtocol> networkManager;
@property (nonatomic, strong, readonly) id<SBBAuthManagerProtocol> authManager;
@property (nonatomic, strong, readonly) id<SBBObjectManagerProtocol> objectManager;

/*!
 Return an SBBXxxManager component (where SBBXxxManager is a concrete subclass of SBBBridgeAPIManager) configured to use the currently-registered auth manager, network manager, and object manager.
 
 @return An SBBXxxManager injected with the dependencies as currently registered.
 */
+ (instancetype)instanceWithRegisteredDependencies;

/*!
 *  Return an SBBXxxManager component (where SBBXxxManager is a concrete subclass of SBBBridgeAPIManager) configured to use the specified auth manager, network manager, and object manager.
 *
 *  Use this method to build a custom configuration, e.g. for testing.
 *
 *  @param authManager    The auth manager to use for authentication. Must implement the SBBAuthManagerProtocol.
 *  @param networkManager The network manager to use for making REST API requests. Must implement the SBBNetworkManagerProtocol.
 *  @param objectManager  The object manager to use for converting between JSON and client objects. Must implement the SBBObjectManagerProtocol.
 *
 *  @return An SBBXxxManager injected with the specified dependencies.
 */
+ (instancetype)managerWithAuthManager:(id<SBBAuthManagerProtocol>)authManager networkManager:(id<SBBNetworkManagerProtocol>)networkManager objectManager:(id<SBBObjectManagerProtocol>)objectManager;

@end
