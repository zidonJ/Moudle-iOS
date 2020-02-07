//
//  ZDRoutes.h
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZDRouteDefinition.h"
#import "ZDRouteRequest.h"
#import "ZDRouteHandler.h"
#import "ZDRouteResponse.h"
#import "ZDParsingUtilities.h"

NS_ASSUME_NONNULL_BEGIN

/// The matching route pattern, passed in the handler parameters.
extern NSString *const ZDRoutePatternKey;

/// The original URL that was routed, passed in the handler parameters.
extern NSString *const ZDRouteURLKey;

/// The matching route scheme, passed in the handler parameters.
extern NSString *const ZDRouteSchemeKey;

/// The wildcard components (if present) of the matching route, passed in the handler parameters.
extern NSString *const ZDRouteWildcardComponentsKey;

/// The global routes namespace.
/// @see ZDRoutes +globalRoutes
extern NSString *const ZDRoutesGlobalRoutesScheme;


@interface ZDRoutes : NSObject

/// Controls whether or not this router will try to match a URL with global routes if it can't be matched in the current namespace. Default is NO.
@property (nonatomic, assign) BOOL shouldFallbackToGlobalRoutes;

/// Called any time routeURL returns NO. Respects shouldFallbackToGlobalRoutes.
@property (nonatomic, copy, nullable) void (^unmatchedURLHandler)(ZDRoutes *routes, NSURL *__nullable URL, NSDictionary<NSString *, id> *__nullable parameters);


///-------------------------------
/// @name Routing Schemes
///-------------------------------


/// Returns the global routing scheme
+ (instancetype)globalRoutes;

/// Returns a routing namespace for the given scheme
+ (instancetype)routesForScheme:(NSString *)scheme;

/// Unregister and delete an entire scheme namespace
+ (void)unregisterRouteScheme:(NSString *)scheme;

/// Unregister all routes
+ (void)unregisterAllRouteSchemes;


///-------------------------------
/// @name Managing Routes
///-------------------------------


/// Add a route by directly inserted the route definition. This may be a subclass of ZDRouteDefinition to provide customized routing logic.
- (void)addRoute:(ZDRouteDefinition *)routeDefinition;

/// Registers a routePattern with default priority (0) in the receiving scheme.
- (void)addRoute:(NSString *)routePattern handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> *parameters))handlerBlock;

/// Registers a routePattern in the global scheme namespace with a handlerBlock to call when the route pattern is matched by a URL.
/// The block returns a BOOL representing if the handlerBlock actually handled the route or not. If
/// a block returns NO, ZDRoutes will continue trying to find a matching route.
- (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> *parameters))handlerBlock;

/// Registers multiple routePatterns for one handler with default priority (0) in the receiving scheme.
- (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^__nullable)(NSDictionary<NSString *, id> *parameters))handlerBlock;

/// Removes the route from the receiving scheme.
- (void)removeRoute:(ZDRouteDefinition *)routeDefinition;

/// Removes the first route matching routePattern from the receiving scheme.
- (void)removeRouteWithPattern:(NSString *)routePattern;

/// Removes all routes from the receiving scheme.
- (void)removeAllRoutes;

/// Registers a routePattern with default priority (0) using dictionary-style subscripting.
- (void)setObject:(nullable id)handlerBlock forKeyedSubscript:(NSString *)routePatten;

/// Return all registered routes in the receiving scheme.
/// @see allRoutes
- (NSArray <ZDRouteDefinition *> *)routes;

/// Return all registered routes across all schemes, keyed by scheme
/// @see routes
+ (NSDictionary <NSString *, NSArray <ZDRouteDefinition *> *> *)allRoutes;


///-------------------------------
/// @name Routing URLs
///-------------------------------


/// Returns YES if the provided URL will successfully match against any registered route, NO if not.
+ (BOOL)canRouteURL:(nullable NSURL *)URL;

/// Returns YES if the provided URL will successfully match against any registered route for the current scheme, NO if not.
- (BOOL)canRouteURL:(nullable NSURL *)URL;

/// Routes a URL, calling handler blocks for patterns that match the URL until one returns YES.
/// If no matching route is found, the unmatchedURLHandler will be called (if set).
+ (BOOL)routeURL:(nullable NSURL *)URL;

/// Routes a URL within a particular scheme, calling handler blocks for patterns that match the URL until one returns YES.
/// If no matching route is found, the unmatchedURLHandler will be called (if set).
- (BOOL)routeURL:(nullable NSURL *)URL;

/// Routes a URL in any routes scheme, calling handler blocks (for patterns that match URL) until one returns YES.
/// Additional parameters get passed through to the matched route block.
+ (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;

/// Routes a URL in a specific scheme, calling handler blocks (for patterns that match URL) until one returns YES.
/// Additional parameters get passed through to the matched route block.
- (BOOL)routeURL:(nullable NSURL *)URL withParameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

@interface ZDRoutes (GlobalOptions)

///----------------------------------
/// @name Configuring Global Options
///----------------------------------

/// Configures verbose logging. Defaults to NO.
+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled;

/// Returns current verbose logging enabled state. Defaults to NO.
+ (BOOL)isVerboseLoggingEnabled;

/// Configures if '+' should be replaced with spaces in parsed values. Defaults to YES.
+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode;

/// Returns if '+' should be replaced with spaces in parsed values. Defaults to YES.
+ (BOOL)shouldDecodePlusSymbols;

/// Configures if URL host is always considered to be a path component. Defaults to NO.
+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent;

/// Returns if URL host is always considered to be a path component. Defaults to NO.
+ (BOOL)alwaysTreatsHostAsPathComponent;

/// Configures the default class to use when creating route definitions. Defaults to ZDRouteDefinition.
+ (void)setDefaultRouteDefinitionClass:(Class)routeDefinitionClass;

/// Returns the default class to use when creating route definitions. Defaults to ZDRouteDefinition.
+ (Class)defaultRouteDefinitionClass;

@end

NS_ASSUME_NONNULL_END
