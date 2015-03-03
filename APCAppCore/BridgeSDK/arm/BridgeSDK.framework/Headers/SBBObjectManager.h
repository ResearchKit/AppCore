//
//  SBBObjectManager.h
//  BridgeSDK
//
//  Created by Erin Mounts on 9/25/14.
//  Copyright (c) 2014 Sage Bionetworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBBComponent.h"

/*!
 This protocol defines the interface to the SBBObjectManager's non-constructor, non-initializer methods. The interface is
 abstracted out for use in mock objects for testing, and to allow selecting among multiple implementations at runtime.
 */
@protocol SBBObjectManagerProtocol <NSObject>

/*!
 *  Create a client object from JSON obtained via the Bridge API.
 *
 *  By default, the object will be an instance (or array) of class SBB<type>, where <type> is the Bridge API object type
 *  as indicated in its "type" field, and SBB<type> is an SBBBridgeObject subclass with properties matching the fields
 *  defined for <type> in the API documentation.
 *
 *  You can override this by setting up a mapping between <type> and a custom class via the
 *  setupMappingForType:toClass:fieldToPropertyMappings: method. In that case API manager methods in this SDK will use
 *  the classes defined in these mappings to pass data back and forth between your app and the Bridge API in place of
 *  the built-in SBB<type> classes.
 *
 *  @param json A JSON object from the Bridge API.
 *
 *  @return A client object (built-in or custom) representing that Bridge API object.
 *
 *  @see bridgeJSONFromObject:
 *  @see setupMappingForType:toClass:fieldToPropertyMappings:
 */
- (id)objectFromBridgeJSON:(id)json;

/*!
 *  Create a Bridge JSON object (or array) from a client object.
 *
 *  If object is an instance of a built-in SBB<type> class, it will be converted into a JSON Bridge object of <type>.
 *
 *  If object is an instance of a class mapped from a type via setupMappingForType:toClass:fieldToPropertyMappings:,
 *  it will be reverse-converted according to the defined mapping to a JSON Bridge object of the mapped-from type.
 *
 *  If the object is an NSDate object, it will be converted to an ISO 8601 date string.
 *
 *  If the object is a standard JSON object (NSArray, NSDictionary, NSString, NSNumber), it will just be returned as-is.
 *
 *  Any other kind of object will be ignored and this method will return nil.
 *
 *  @param object The client object to convert to JSON for the Bridge API.
 *
 *  @return JSON representing that client object.
 *
 *  @see objectFromBridgeJSON:
 *  @see setupMappingForType:toClass:fieldToPropertyMappings:
 */
- (id)bridgeJSONFromObject:(id)object;

/*!
 *  Set up an SDK-wide mapping between Bridge API objects of a specified type and a particular client class, with
 *  Bridge object field names mapped to class properties according to a given dictionary.
 *
 *  By default, unless an explicit mapping has been set up for a given Bridge API object type, the mapping will be done
 *  to an internal class named SBB<type> with property names matching the field names defined for the Bridge API object type.
 *
 *  @param type       The Bridge API type being mapped.
 *  @param mapToClass The client class to which it is to be mapped.
 *  @param mappings   Keys are Bridge API field names; values are the corresponding class property names. A nil value for this parameter will cause the SDK to use the Bridge API field names as the corresponding class property names.
 */
- (void)setupMappingForType:(NSString *)type toClass:(Class)mapToClass fieldToPropertyMappings:(NSDictionary *)mappings;

/*!
 *  Clear any previously set up SDK-wide mapping of Bridge API objects of the specified type.
 *
 *  The implicit mapping will revert to an internal class named SBB<type> with property names matching the field names
 *  defined for the Bridge API object type.
 *
 *  @param type       The Bridge API type being un-mapped.
 */
- (void)clearMappingForType:(NSString *)type;

@end

/*!
 *  This class handles converting between Bridge API JSON objects and corresponding client objects. It is used internally
 *  by the various API managers for that purpose.
 */
@interface SBBObjectManager : NSObject<SBBComponent, SBBObjectManagerProtocol>

/*!
 *  Use this method to create an independent object manager instance for testing.
 *
 *  @return A fresh SBBObjectManager instance.
 */
+ (instancetype)objectManager;

@end
