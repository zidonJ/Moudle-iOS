//
//  ZDRouteRequest.h
//  ZDoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Options bitmask generated from ZDoutes global options methods.
typedef NS_OPTIONS(NSUInteger, ZDRouteRequestOptions) {
    /// No options specified.
    ZDRouteRequestOptionsNone = 0,
    
    /// If present, decoding plus symbols is enabled.
    ZDRouteRequestOptionDecodePlusSymbols = 1 << 0,
    
    /// If present, treating URL hosts as path components is enabled.
    ZDRouteRequestOptionTreatHostAsPathComponent = 1 << 1
};


@interface ZDRouteRequest : NSObject

/// The URL being routed.
@property (nonatomic, copy, readonly) NSURL *URL;

/// The URL's path components.
@property (nonatomic, strong, readonly) NSArray *pathComponents;

/// The URL's query parameters.
@property (nonatomic, strong, readonly) NSDictionary *queryParams;

/// Route request options, generally configured from the framework global options.
@property (nonatomic, assign, readonly) ZDRouteRequestOptions options;

/// Additional parameters to pass through as part of the match parameters dictionary.
@property (nonatomic, copy, nullable, readonly) NSDictionary *additionalParameters;


///-------------------------------
/// @name Creating Route Requests
///-------------------------------


/**
 Creates a new route request.
 
 @param URL The URL to route.
 @param options Options bitmask specifying parsing behavior.
 @param additionalParameters Additional parameters to include in any match dictionary created against this request.
 
 @returns The newly initialized route request.
 */
- (instancetype)initWithURL:(NSURL *)URL options:(ZDRouteRequestOptions)options additionalParameters:(nullable NSDictionary *)additionalParameters NS_DESIGNATED_INITIALIZER;

/// Unavailable, use initWithURL:options:additionalParameters: instead.
- (instancetype)init NS_UNAVAILABLE;

/// Unavailable, use initWithURL:options:additionalParameters: instead.
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
