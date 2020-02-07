//
//  ZDRouteDefinition.h
//  ZDoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDRouteRequest.h"
#import "ZDRouteResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZDRouteDefinition : NSObject <NSCopying>

/// The URL scheme for which this route applies, or ZDoutesGlobalRoutesScheme if global.
@property (nonatomic, copy, readonly) NSString *scheme;

/// The route pattern.
@property (nonatomic, copy, readonly) NSString *pattern;

/// The priority of this route pattern.
@property (nonatomic, assign, readonly) NSUInteger priority;

/// The route pattern path components.
@property (nonatomic, copy, readonly) NSArray <NSString *> *patternPathComponents;

/// The handler block to invoke when a match is found.
@property (nonatomic, copy, readonly) BOOL (^handlerBlock)(NSDictionary *parameters);

/// Check for route definition equality.
- (BOOL)isEqualToRouteDefinition:(ZDRouteDefinition *)routeDefinition;


///----------------------------------
/// @name Creating Route Definitions
///----------------------------------


/**
 Creates a new route definition. The created definition can be directly added to an instance of ZDoutes.
 
 This is the designated initializer.
 
 @param pattern The full route pattern ('/foo/:bar')
 @param priority The route priority, or 0 if default.
 @param handlerBlock The handler block to call when a successful match is found.
 
 @returns The newly initialized route definition.
 */
- (instancetype)initWithPattern:(NSString *)pattern priority:(NSUInteger)priority handlerBlock:(BOOL (^)(NSDictionary *parameters))handlerBlock NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithScheme:pattern:priority:handlerBlock: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithScheme:pattern:priority:handlerBlock: instead.
+ (instancetype)new NS_UNAVAILABLE;


///----------------------------------
/// @name Responding To Registration
///----------------------------------


/**
 Called when the route has been registered for the given scheme.
 
 @param scheme The scheme this route has become active for.
 */
- (void)didBecomeRegisteredForScheme:(NSString *)scheme;


///-------------------------------
/// @name Matching Route Requests
///-------------------------------


/**
 Creates and returns a ZDRouteResponse for the provided ZDRouteRequest. The response specifies if there was a match or not.
 
 @param request The ZDRouteRequest to create a response for.
 
 @returns An ZDRouteResponse instance representing the result of attempting to match request to thie route definition.
 */
- (ZDRouteResponse *)routeResponseForRequest:(ZDRouteRequest *)request;


/**
 Invoke handlerBlock with the given parameters. This may be overriden by subclasses.
 
 @param parameters The parameters to pass to handlerBlock.
 
 @returns The value returned by calling handlerBlock (YES if it is considered handled and NO if not).
 */
- (BOOL)callHandlerBlockWithParameters:(NSDictionary *)parameters;


///---------------------------------
/// @name Creating Match Parameters
///---------------------------------


/**
 Creates and returns the full set of match parameters to be passed as part of a valid match.
 Subclasses can override this method to mutate the match parameters, or simply call it to generate the expected value.
 
 @param request The request being routed.
 @param routeVariables The parsed route variables (aka a route of '/route/:param' being routed with '/foo/bar' would create [ 'param' : 'bar' ])
 
 @returns The full set of match parameters to be passed as part of a valid match.
 @see defaultMatchParametersForRequest:
 @see routeVariablesForRequest:
 */
- (NSDictionary *)matchParametersForRequest:(ZDRouteRequest *)request routeVariables:(NSDictionary <NSString *, NSString *> *)routeVariables;


/**
 Creates and returns the default base match parameters for a given request. Does not include any parsed fields.
 
 @param request The request being routed.
 
 @returns The default match parameters for a given request. Only includes key/value pairs for ZDoutePatternKey, ZDouteURLKey, and ZDouteSchemeKey.
 */
- (NSDictionary *)defaultMatchParametersForRequest:(ZDRouteRequest *)request;


///-------------------------------
/// @name Parsing Route Variables
///-------------------------------


/**
 Parses and returns route variables for the given request.
 
 @param request The request to parse variable values from.
 
 @returns The parsed route variables if there was a match, or nil if it was not a match.
 */
- (nullable NSDictionary <NSString *, NSString *> *)routeVariablesForRequest:(ZDRouteRequest *)request;


/**
 Parses value into a variable name, including stripping out any extra characters if needed.
 
 @param value The raw string value that should be parsed into a variable name.
 
 @returns The variable name to use as the key of a key/value pair in the parsed route variables.
 */
- (NSString *)routeVariableNameForValue:(NSString *)value;


/**
 Parses value into a variable value, including stripping out any extra characters if needed.
 
 @param value The raw string value that should be parsed into a variable value.
 
 @returns The variable value to use as the value of a key/value pair in the parsed route variables.
 */
- (NSString *)routeVariableValueForValue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
