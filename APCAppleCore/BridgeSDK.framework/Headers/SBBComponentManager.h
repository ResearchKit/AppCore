//
//  SBBComponentManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/16/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A convenience macro for obtaining the registered or default component instance for a given componentClass.
 *
 * This is the preferred method for accessing Bridge SDK components throughout your app, both to ensure the proper
 * runtime implementation is used, and to simplify transparent testing of individual components by registering mocks
 * for other components on which the tested component depends, which will then be automatically used by all code that
 * accesses those components through this macro or the underlying SBBComponentManager component: class method.
 *
 *  @param componentClass The class for which to retrieve the registered component instance.
 *
 *  @return The component instance registered for this class, cast to an id implementing the corresponding protocol.
 */
#define SBBComponent(componentClass) ((id<componentClass ## Protocol>)[SBBComponentManager component:[componentClass class]])

/**
 *  A convenience macro for obtaining the component instance registered for a given componentClass when that instance
 *  is a test mock implementation whose class interface may include additional test-configuration-related methods.
 *
 *  @param testClass      The class of the test mock implementation.
 *  @param componentClass The class for which the test mock is registered as the component instance.
 *
 *  @return The registered component instance, cast to (testClass *).
 */
#define SBBTestComponent(testClass, componentClass) ((testClass *)[SBBComponentManager component:[componentClass class]])

/**
 * This class provides a central point for managing singleton components, to simplify use of dependency injection
 * in the default case, when needing runtime selection between two or more implementations, and mocking for testing.
 *
 * In general, you should access all such components through this class, either via the component: class method
 * or one of the convenience macros SBBComponent(class) or SBBTestComponent(testClass, class).
 */
@interface SBBComponentManager : NSObject

/**
 *  Register a specific component instance to be returned by requests for components registered to a given class.
 *
 *  This method can be used both for registering mock components for testing purposes, and for handling the
 *  case where you need to choose one of two or more alternative implementations at runtime based on criteria
 *  not available at compile time.
 *
 *  @param componentInstance The component instance to register for the given componentClass.
 *  @param componentClass    The class for which to register the given component.
 *
 *  @return The component instance, if any, previously registered for the given componentClass.
 */
+ (id)registerComponent:(id)componentInstance forClass:(Class)componentClass;

/**
 *  Return the registered instance of the component for the given class.
 *
 *  If no instance is registered, and componentClass implements the SBBComponent protocol, this method will
 *  call the class's defaultComponent: class method and register the returned value as the instance for the class.
 *
 *  @param componentClass The class for which to get (or instantiate and register) the registered component instance.
 *
 *  @return The registered instance for the given componentClass.
 */
+ (id)component:(Class)componentClass;

@end
