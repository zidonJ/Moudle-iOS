//
//  ZDRouteHandler.m
//  JLRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import "ZDRouteHandler.h"

@implementation ZDRouteHandler

+ (BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlockForWeakTarget:(__weak id <ZDRouteHandlerTarget>)weakTarget
{
    NSParameterAssert([weakTarget respondsToSelector:@selector(handleRouteWithParameters:)]);
    
    return ^BOOL(NSDictionary<NSString *, id> *parameters) {
        return [weakTarget handleRouteWithParameters:parameters];
    };
}

+ (BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlockForTargetClass:(Class)targetClass completion:(BOOL (^)(id <ZDRouteHandlerTarget> createdObject))completionHandler
{
    NSParameterAssert([targetClass conformsToProtocol:@protocol(ZDRouteHandlerTarget)]);
    NSParameterAssert([targetClass instancesRespondToSelector:@selector(initWithRouteParameters:)]);
    NSParameterAssert(completionHandler != nil); // we want to force external ownership of the newly created object by handing it back.
    
    return ^BOOL(NSDictionary<NSString *, id> *parameters) {
        id <ZDRouteHandlerTarget> createdObject = [[targetClass alloc] initWithRouteParameters:parameters];
        return completionHandler(createdObject);
    };
}

@end
