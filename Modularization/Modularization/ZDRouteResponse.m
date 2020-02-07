//
//  ZDRouteResponse.m
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import "ZDRouteResponse.h"

@interface ZDRouteResponse ()

@property (nonatomic, assign, getter=isMatch) BOOL match;
@property (nonatomic, copy) NSDictionary *parameters;

@end


@implementation ZDRouteResponse

+ (instancetype)invalidMatchResponse
{
    ZDRouteResponse *response = [[[self class] alloc] init];
    response.match = NO;
    return response;
}

+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters
{
    ZDRouteResponse *response = [[[self class] alloc] init];
    response.match = YES;
    response.parameters = parameters;
    return response;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p> - match: %@, params: %@", NSStringFromClass([self class]), self, (self.match ? @"YES" : @"NO"), self.parameters];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToRouteResponse:(ZDRouteResponse *)object];
    } else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqualToRouteResponse:(ZDRouteResponse *)response
{
    if (self.isMatch != response.isMatch) {
        return NO;
    }
    
    if (!((self.parameters == nil && response.parameters == nil) || [self.parameters isEqualToDictionary:response.parameters])) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return @(self.match).hash ^ self.parameters.hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    ZDRouteResponse *copy = [[[self class] alloc] init];
    copy.match = self.isMatch;
    copy.parameters = self.parameters;
    return copy;
}

@end

