//
//  ZDRouteHandler.h
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZDRouteHandlerTarget;

@interface ZDRouteHandler : NSObject

/// Unavailable.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable.
+ (instancetype)new NS_UNAVAILABLE;


/**
 Creates and returns a block that calls handleRouteWithParameters: on a weak target objet.
 
 The block returned from this method should be passed as the handler block of an addRoute: call.
 
 @param weakTarget The target object that should handle a matched route.
 
 @returns A new handler block for the provided weakTarget.
 
 @discussion There is no change of ownership of the target object, only a weak pointer (hence 'weakTarget') is captured in the block.
 If the object is deallocated, the handler will no longer be called (but the route will remain registered unless explicitly removed).
 */

+ (BOOL (^__nonnull)(NSDictionary<NSString *, id> *parameters))handlerBlockForWeakTarget:(__weak id <ZDRouteHandlerTarget>)weakTarget;


/**
 Creates and returns a block that creates a new instance of targetClass (which must conform to ZDRouteHandlerTarget), and then calls
 handleRouteWithParameters: on it. The created object is then passed as the parameter to the completion block.
 
 The block returned from this method should be passed as the handler block of an addRoute: call.
 
 @param targetClass The target class to create for handling the route request. Must conform to ZDRouteHandlerTarget.
 @param completionHandler The completion block to call after creating the new targetClass instance.
 
 @returns A new handler block for creating instances of targetClass.
 
 @discussion ZDoutes does not retain or own the created object. It's expected that the created object that is passed through the completion handler
 will be used and owned by the calling application.
 */

+ (BOOL (^__nonnull)(NSDictionary<NSString *, id> *parameters))handlerBlockForTargetClass:(Class)targetClass completion:(BOOL (^)(id <ZDRouteHandlerTarget> createdObject))completionHandler;

@end


/**
 Classes conforming to the ZDRouteHandlerTarget protocol can be used as a route handler target.
 */

@protocol ZDRouteHandlerTarget <NSObject>

@optional

/**
 Initialize an instance of the conforming class by passing matched route parameters from a ZDoutes route.
 
 @param parameters The match parameters passed to use when initializing the object. These are passed from a ZDoutes handler block.
 
 @returns An initialized instance of the conforming class.
 */

- (instancetype)initWithRouteParameters:(NSDictionary <NSString *, id> *)parameters;


/**
 Called for a successful route match.
 
 @param parameters The match parameters passed to the handler block.
 
 @returns YES if the route was handled, NO if matching a different route should be attempted.
 */

- (BOOL)handleRouteWithParameters:(NSDictionary<NSString *, id> *)parameters;


@end

NS_ASSUME_NONNULL_END
