//
//  ZDParsingUtilities.m
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import "ZDParsingUtilities.h"

@interface NSArray (ZDRoutes_Utilities)

- (NSArray<NSArray *> *)ZDRoutes_allOrderedCombinations;
- (NSArray *)ZDRoutes_filter:(BOOL (^)(id object))filterBlock;
- (NSArray *)ZDRoutes_map:(id (^)(id object))mapBlock;

@end


@interface NSString (ZDRoutes_Utilities)

- (NSArray <NSString *> *)ZDRoutes_trimmedPathComponents;

@end


#pragma mark - Parsing Utility Methods


@interface ZDRParsingUtilities_RouteSubpath : NSObject

@property (nonatomic, strong) NSArray <NSString *> *subpathComponents;
@property (nonatomic, assign) BOOL isOptionalSubpath;

@end


@implementation ZDRParsingUtilities_RouteSubpath

- (NSString *)description
{
    NSString *type = self.isOptionalSubpath ? @"OPTIONAL" : @"REQUIRED";
    return [NSString stringWithFormat:@"%@ - %@: %@", [super description], type, [self.subpathComponents componentsJoinedByString:@"/"]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    ZDRParsingUtilities_RouteSubpath *otherSubpath = (ZDRParsingUtilities_RouteSubpath *)object;
    if (![self.subpathComponents isEqual:otherSubpath.subpathComponents]) {
        return NO;
    }
    
    if (self.isOptionalSubpath != otherSubpath.isOptionalSubpath) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return self.subpathComponents.hash ^ self.isOptionalSubpath;
}

@end


@implementation ZDParsingUtilities

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols
{
    if (!decodePlusSymbols) {
        return value;
    }
    return [value stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, value.length)];
}

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlusSymbols:(BOOL)decodePlusSymbols
{
    if (!decodePlusSymbols) {
        return queryParams;
    }
    
    NSMutableDictionary *updatedQueryParams = [NSMutableDictionary dictionary];
    
    for (NSString *name in queryParams) {
        id value = queryParams[name];
        
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *variables = [NSMutableArray array];
            for (NSString *arrayValue in (NSArray *)value) {
                [variables addObject:[self variableValueFrom:arrayValue decodePlusSymbols:YES]];
            }
            updatedQueryParams[name] = [variables copy];
        } else if ([value isKindOfClass:[NSString class]]) {
            NSString *variable = [self variableValueFrom:value decodePlusSymbols:YES];
            updatedQueryParams[name] = variable;
        } else {
            NSAssert(NO, @"Unexpected query parameter type: %@", NSStringFromClass([value class]));
        }
    }
    
    return [updatedQueryParams copy];
}

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern
{
    /* this method exists to take a route pattern that is known to contain optional params, such as:
     
     /path/:thing/(/a)(/b)(/c)
     
     and create the following paths:
     
     /path/:thing/a/b/c
     /path/:thing/a/b
     /path/:thing/a/c
     /path/:thing/b/a
     /path/:thing/a
     /path/:thing/b
     /path/:thing/c
     
     */
    
    if ([routePattern rangeOfString:@"("].location == NSNotFound) {
        return @[];
    }
    
    // First, parse the route pattern into subpath objects.
    NSArray <ZDRParsingUtilities_RouteSubpath *> *subpaths = [self _routeSubpathsForPattern:routePattern];
    if (subpaths.count == 0) {
        return @[];
    }
    
    // Next, etract out the required subpaths.
    NSSet <ZDRParsingUtilities_RouteSubpath *> *requiredSubpaths = [NSSet setWithArray:[subpaths ZDRoutes_filter:^BOOL(ZDRParsingUtilities_RouteSubpath *subpath) {
        return !subpath.isOptionalSubpath;
    }]];
    
    // Then, expand the subpath permutations into possible route patterns.
    NSArray <NSArray <ZDRParsingUtilities_RouteSubpath *> *> *allSubpathCombinations = [subpaths ZDRoutes_allOrderedCombinations];
    
    // Finally, we need to filter out any possible route patterns that don't actually satisfy the rules of the route.
    // What this means in practice is throwing out any that do not contain all required subpaths (since those are explicitly not optional).
    NSArray <NSArray <ZDRParsingUtilities_RouteSubpath *> *> *validSubpathCombinations = [allSubpathCombinations ZDRoutes_filter:^BOOL(NSArray <ZDRParsingUtilities_RouteSubpath *> *possibleRouteSubpaths) {
        return [requiredSubpaths isSubsetOfSet:[NSSet setWithArray:possibleRouteSubpaths]];
    }];
    
    // Once we have a filtered list of valid subpaths, we just need to convert them back into string routes that can we registered.
    NSArray <NSString *> *validSubpathRouteStrings = [validSubpathCombinations ZDRoutes_map:^id(NSArray <ZDRParsingUtilities_RouteSubpath *> *subpaths) {
        NSString *routePattern = @"/";
        for (ZDRParsingUtilities_RouteSubpath *subpath in subpaths) {
            NSString *subpathString = [subpath.subpathComponents componentsJoinedByString:@"/"];
            routePattern = [routePattern stringByAppendingPathComponent:subpathString];
        }
        return routePattern;
    }];
    
    // Before returning, sort them by length so that the longest and most specific routes are registered first before the less specific shorter ones.
    validSubpathRouteStrings = [validSubpathRouteStrings sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"length" ascending:NO selector:@selector(compare:)]]];
    
    return validSubpathRouteStrings;
}

+ (NSArray <ZDRParsingUtilities_RouteSubpath *> *)_routeSubpathsForPattern:(NSString *)routePattern
{
    NSMutableArray <ZDRParsingUtilities_RouteSubpath *> *subpaths = [NSMutableArray array];
    
    NSScanner *scanner = [NSScanner scannerWithString:routePattern];
    while (![scanner isAtEnd]) {
        NSString *preOptionalSubpath = nil;
        BOOL didScan = [scanner scanUpToString:@"(" intoString:&preOptionalSubpath];
        if (!didScan) {
            NSAssert([routePattern characterAtIndex:scanner.scanLocation] == '(', @"Unexpected character: %c", [routePattern characterAtIndex:scanner.scanLocation]);
        }
        
        if (!scanner.isAtEnd) {
            // otherwise, advance past the ( character
            scanner.scanLocation = scanner.scanLocation + 1;
        }
        
        if (preOptionalSubpath.length > 0 && ![preOptionalSubpath isEqualToString:@")"] && ![preOptionalSubpath isEqualToString:@"/"]) {
            // content before the start of an optional subpath
            ZDRParsingUtilities_RouteSubpath *subpath = [[ZDRParsingUtilities_RouteSubpath alloc] init];
            subpath.subpathComponents = [preOptionalSubpath ZDRoutes_trimmedPathComponents];
            [subpaths addObject:subpath];
        }
        
        if (scanner.isAtEnd) {
            break;
        }
        
        NSString *optionalSubpath = nil;
        didScan = [scanner scanUpToString:@")" intoString:&optionalSubpath];
        NSAssert(didScan, @"Could not find closing parenthesis");
        
        scanner.scanLocation = scanner.scanLocation + 1;
        
        if (optionalSubpath.length > 0) {
            ZDRParsingUtilities_RouteSubpath *subpath = [[ZDRParsingUtilities_RouteSubpath alloc] init];
            subpath.isOptionalSubpath = YES;
            subpath.subpathComponents = [optionalSubpath ZDRoutes_trimmedPathComponents];
            [subpaths addObject:subpath];
        }
    }
    
    return [subpaths copy];
}

@end


#pragma mark - Categories


@implementation NSArray (ZDRoutes_Utilities)

- (NSArray<NSArray *> *)ZDRoutes_allOrderedCombinations
{
    NSInteger length = self.count;
    if (length == 0) {
        return [NSArray arrayWithObject:[NSArray array]];
    }
    
    id lastObject = [self lastObject];
    NSArray *subarray = [self subarrayWithRange:NSMakeRange(0, length - 1)];
    NSArray *subarrayCombinations = [subarray ZDRoutes_allOrderedCombinations];
    NSMutableArray *combinations = [NSMutableArray arrayWithArray:subarrayCombinations];
    
    for (NSArray *subarrayCombos in subarrayCombinations) {
        [combinations addObject:[subarrayCombos arrayByAddingObject:lastObject]];
    }
    
    return [NSArray arrayWithArray:combinations];
}

- (NSArray *)ZDRoutes_filter:(BOOL (^)(id object))filterBlock
{
    NSParameterAssert(filterBlock != nil);
    NSMutableArray *filteredArray = [NSMutableArray array];
    
    for (id object in self) {
        if (filterBlock(object)) {
            [filteredArray addObject:object];
        }
    }
    
    return [filteredArray copy];
}

- (NSArray *)ZDRoutes_map:(id (^)(id object))mapBlock
{
    NSParameterAssert(mapBlock != nil);
    NSMutableArray *mappedArray = [NSMutableArray array];
    
    for (id object in self) {
        id mappedObject = mapBlock(object);
        [mappedArray addObject:mappedObject];
    }
    
    return [mappedArray copy];
}

@end


@implementation NSString (ZDRoutes_Utilities)

- (NSArray <NSString *> *)ZDRoutes_trimmedPathComponents
{
    // Trims leading and trailing slashes and then separates by slash
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]] componentsSeparatedByString:@"/"];
}

@end
