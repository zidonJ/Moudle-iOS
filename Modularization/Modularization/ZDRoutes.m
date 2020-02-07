//
//  ZDRoutes.m
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import "ZDRoutes.h"

NSString *const ZDRoutePatternKey = @"ZDRoutePattern";
NSString *const ZDRouteURLKey = @"ZDRouteURL";
NSString *const ZDRouteSchemeKey = @"ZDRouteScheme";
NSString *const ZDRouteWildcardComponentsKey = @"ZDRouteWildcardComponents";
NSString *const ZDRoutesGlobalRoutesScheme = @"ZDRoutesGlobalRoutesScheme";


static NSMutableDictionary *JLRGlobal_routeControllersMap = nil;


// global options (configured in +initialize)
static BOOL JLRGlobal_verboseLoggingEnabled;
static BOOL JLRGlobal_shouldDecodePlusSymbols;
static BOOL JLRGlobal_alwaysTreatsHostAsPathComponent;
static Class JLRGlobal_routeDefinitionClass;


@interface ZDRoutes ()

@property (nonatomic, strong) NSMutableArray *mutableRoutes;
@property (nonatomic, strong) NSString *scheme;

- (ZDRouteRequestOptions)_routeRequestOptions;

@end

@implementation ZDRoutes

+ (void)initialize
{
    if (self == [ZDRoutes class]) {
        // Set default global options
        JLRGlobal_verboseLoggingEnabled = NO;
        JLRGlobal_shouldDecodePlusSymbols = YES;
        JLRGlobal_alwaysTreatsHostAsPathComponent = NO;
        JLRGlobal_routeDefinitionClass = [ZDRouteDefinition class];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
        self.mutableRoutes = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
    return [self.mutableRoutes description];
}

+ (NSDictionary <NSString *, NSArray <ZDRouteDefinition *> *> *)allRoutes;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    for (NSString *namespace in [JLRGlobal_routeControllersMap copy]) {
        ZDRoutes *routesController = JLRGlobal_routeControllersMap[namespace];
        dictionary[namespace] = [routesController.mutableRoutes copy];
    }
    
    return [dictionary copy];
}


#pragma mark - Routing Schemes

+ (instancetype)globalRoutes
{
    return [self routesForScheme:ZDRoutesGlobalRoutesScheme];
}

+ (instancetype)routesForScheme:(NSString *)scheme
{
    ZDRoutes *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        JLRGlobal_routeControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!JLRGlobal_routeControllersMap[scheme]) {
        routesController = [[self alloc] init];
        routesController.scheme = scheme;
        JLRGlobal_routeControllersMap[scheme] = routesController;
    }
    
    routesController = JLRGlobal_routeControllersMap[scheme];
    
    return routesController;
}

+ (void)unregisterRouteScheme:(NSString *)scheme
{
    [JLRGlobal_routeControllersMap removeObjectForKey:scheme];
}

+ (void)unregisterAllRouteSchemes
{
    [JLRGlobal_routeControllersMap removeAllObjects];
}


#pragma mark - Registering Routes

- (void)addRoute:(ZDRouteDefinition *)routeDefinition
{
    [self _registerRoute:routeDefinition];
}

- (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    [self addRoute:routePattern priority:0 handler:handlerBlock];
}

- (void)addRoutes:(NSArray<NSString *> *)routePatterns handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    for (NSString *routePattern in routePatterns) {
        [self addRoute:routePattern handler:handlerBlock];
    }
}

- (void)addRoute:(NSString *)routePattern priority:(NSUInteger)priority handler:(BOOL (^)(NSDictionary<NSString *, id> *parameters))handlerBlock
{
    NSArray <NSString *> *optionalRoutePatterns = [ZDParsingUtilities expandOptionalRoutePatternsForPattern:routePattern];
    ZDRouteDefinition *route = [[JLRGlobal_routeDefinitionClass alloc] initWithPattern:routePattern priority:priority handlerBlock:handlerBlock];
    
    if (optionalRoutePatterns.count > 0) {
        // there are optional params, parse and add them
        for (NSString *pattern in optionalRoutePatterns) {
            ZDRouteDefinition *optionalRoute = [[JLRGlobal_routeDefinitionClass alloc] initWithPattern:pattern priority:priority handlerBlock:handlerBlock];
            [self _registerRoute:optionalRoute];
            [self _verboseLog:@"Automatically created optional route: %@", optionalRoute];
        }
        return;
    }
    
    [self _registerRoute:route];
}

- (void)removeRoute:(ZDRouteDefinition *)routeDefinition
{
    [self.mutableRoutes removeObject:routeDefinition];
}

- (void)removeRouteWithPattern:(NSString *)routePattern
{
    NSInteger routeIndex = NSNotFound;
    NSInteger index = 0;
    
    for (ZDRouteDefinition *route in [self.mutableRoutes copy]) {
        if ([route.pattern isEqualToString:routePattern]) {
            routeIndex = index;
            break;
        }
        index++;
    }
    
    if (routeIndex != NSNotFound) {
        [self.mutableRoutes removeObjectAtIndex:(NSUInteger)routeIndex];
    }
}

- (void)removeAllRoutes
{
    [self.mutableRoutes removeAllObjects];
}

- (void)setObject:(id)handlerBlock forKeyedSubscript:(NSString *)routePatten
{
    [self addRoute:routePatten handler:handlerBlock];
}

- (NSArray <ZDRouteDefinition *> *)routes;
{
    return [self.mutableRoutes copy];
}

#pragma mark - Routing URLs

+ (BOOL)canRouteURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] canRouteURL:URL];
}

- (BOOL)canRouteURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:NO];
}

+ (BOOL)routeURL:(NSURL *)URL
{
    return [[self _routesControllerForURL:URL] routeURL:URL];
}

- (BOOL)routeURL:(NSURL *)URL
{
    return [self _routeURL:URL withParameters:nil executeRouteBlock:YES];
}

+ (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [[self _routesControllerForURL:URL] routeURL:URL withParameters:parameters];
}

- (BOOL)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self _routeURL:URL withParameters:parameters executeRouteBlock:YES];
}


#pragma mark - Private

+ (instancetype)_routesControllerForURL:(NSURL *)URL
{
    if (URL == nil) {
        return nil;
    }
    
    return JLRGlobal_routeControllersMap[URL.scheme] ?: [ZDRoutes globalRoutes];
}

- (void)_registerRoute:(ZDRouteDefinition *)route
{
    if (route.priority == 0 || self.mutableRoutes.count == 0) {
        [self.mutableRoutes addObject:route];
    } else {
        NSUInteger index = 0;
        BOOL addedRoute = NO;
        
        // search through existing routes looking for a lower priority route than this one
        for (ZDRouteDefinition *existingRoute in [self.mutableRoutes copy]) {
            if (existingRoute.priority < route.priority) {
                // if found, add the route after it
                [self.mutableRoutes insertObject:route atIndex:index];
                addedRoute = YES;
                break;
            }
            index++;
        }
        
        // if we weren't able to find a lower priority route, this is the new lowest priority route (or same priority as self.routes.lastObject) and should just be added
        if (!addedRoute) {
            [self.mutableRoutes addObject:route];
        }
    }
    
    [route didBecomeRegisteredForScheme:self.scheme];
}

- (BOOL)_routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock
{
    if (!URL) {
        return NO;
    }
    
    [self _verboseLog:@"Trying to route URL %@", URL];
    
    BOOL didRoute = NO;
    
    ZDRouteRequestOptions options = [self _routeRequestOptions];
    ZDRouteRequest *request = [[ZDRouteRequest alloc] initWithURL:URL options:options additionalParameters:parameters];
    
    for (ZDRouteDefinition *route in [self.mutableRoutes copy]) {
        // check each route for a matching response
        ZDRouteResponse *response = [route routeResponseForRequest:request];
        if (!response.isMatch) {
            continue;
        }
        
        [self _verboseLog:@"Successfully matched %@", route];
        
        if (!executeRouteBlock) {
            // if we shouldn't execute but it was a match, we're done now
            return YES;
        }
        
        [self _verboseLog:@"Match parameters are %@", response.parameters];
        
        // Call the handler block
        didRoute = [route callHandlerBlockWithParameters:response.parameters];
        
        if (didRoute) {
            // if it was routed successfully, we're done - otherwise, continue trying to route
            break;
        }
    }
    
    if (!didRoute) {
        [self _verboseLog:@"Could not find a matching route"];
    }
    
    // if we couldn't find a match and this routes controller specifies to fallback and its also not the global routes controller, then...
    if (!didRoute && self.shouldFallbackToGlobalRoutes && ![self _isGlobalRoutesController]) {
        [self _verboseLog:@"Falling back to global routes..."];
        didRoute = [[ZDRoutes globalRoutes] _routeURL:URL withParameters:parameters executeRouteBlock:executeRouteBlock];
    }
    
    // if, after everything, we did not route anything and we have an unmatched URL handler, then call it
    if (!didRoute && executeRouteBlock && self.unmatchedURLHandler) {
        [self _verboseLog:@"Falling back to the unmatched URL handler"];
        self.unmatchedURLHandler(self, URL, parameters);
    }
    
    return didRoute;
}

- (BOOL)_isGlobalRoutesController
{
    return [self.scheme isEqualToString:ZDRoutesGlobalRoutesScheme];
}

- (void)_verboseLog:(NSString *)format, ...
{
    if (!JLRGlobal_verboseLoggingEnabled || format.length == 0) {
        return;
    }
    
    va_list argsList;
    va_start(argsList, format);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wformat-nonliteral"
    NSString *formattedLogMessage = [[NSString alloc] initWithFormat:format arguments:argsList];
#pragma clang diagnostic pop
    
    va_end(argsList);
    NSLog(@"[ZDRoutes]: %@", formattedLogMessage);
}

- (ZDRouteRequestOptions)_routeRequestOptions
{
    ZDRouteRequestOptions options = ZDRouteRequestOptionsNone;
    
    if (JLRGlobal_shouldDecodePlusSymbols) {
        options |= ZDRouteRequestOptionDecodePlusSymbols;
    }
    if (JLRGlobal_alwaysTreatsHostAsPathComponent) {
        options |= ZDRouteRequestOptionTreatHostAsPathComponent;
    }
    
    return options;
}

@end


#pragma mark - Global Options

@implementation ZDRoutes (GlobalOptions)

+ (void)setVerboseLoggingEnabled:(BOOL)loggingEnabled
{
    JLRGlobal_verboseLoggingEnabled = loggingEnabled;
}

+ (BOOL)isVerboseLoggingEnabled
{
    return JLRGlobal_verboseLoggingEnabled;
}

+ (void)setShouldDecodePlusSymbols:(BOOL)shouldDecode
{
    JLRGlobal_shouldDecodePlusSymbols = shouldDecode;
}

+ (BOOL)shouldDecodePlusSymbols
{
    return JLRGlobal_shouldDecodePlusSymbols;
}

+ (void)setAlwaysTreatsHostAsPathComponent:(BOOL)treatsHostAsPathComponent
{
    JLRGlobal_alwaysTreatsHostAsPathComponent = treatsHostAsPathComponent;
}

+ (BOOL)alwaysTreatsHostAsPathComponent
{
    return JLRGlobal_alwaysTreatsHostAsPathComponent;
}

+ (void)setDefaultRouteDefinitionClass:(Class)routeDefinitionClass
{
    NSParameterAssert([routeDefinitionClass isSubclassOfClass:[ZDRouteDefinition class]]);
    JLRGlobal_routeDefinitionClass = routeDefinitionClass;
}

+ (Class)defaultRouteDefinitionClass
{
    return JLRGlobal_routeDefinitionClass;
}

@end
