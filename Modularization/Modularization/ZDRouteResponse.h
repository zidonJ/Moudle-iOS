//
//  ZDRouteResponse.h
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDRouteResponse : NSObject <NSCopying>

/// Indicates if the response is a match or not.
@property (nonatomic, assign, readonly, getter=isMatch) BOOL match;

/// The match parameters (or nil for an invalid response).
@property (nonatomic, copy, readonly, nullable) NSDictionary *parameters;

/// Check for route response equality
- (BOOL)isEqualToRouteResponse:(ZDRouteResponse *)response;


///-------------------------------
/// @name Creating Responses
///-------------------------------


/// Creates an invalid match response.
+ (instancetype)invalidMatchResponse;

/// Creates a valid match response with the given parameters.
+ (instancetype)validMatchResponseWithParameters:(NSDictionary *)parameters;

/// Unavailable, please use +invalidMatchResponse or +validMatchResponseWithParameters: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, please use +invalidMatchResponse or +validMatchResponseWithParameters: instead.
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
