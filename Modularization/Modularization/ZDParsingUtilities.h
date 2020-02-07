//
//  ZDParsingUtilities.h
//  ZDRoutes
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 Afterwork Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZDParsingUtilities : NSObject

+ (NSString *)variableValueFrom:(NSString *)value decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSDictionary *)queryParams:(NSDictionary *)queryParams decodePlusSymbols:(BOOL)decodePlusSymbols;

+ (NSArray <NSString *> *)expandOptionalRoutePatternsForPattern:(NSString *)routePattern;

@end

NS_ASSUME_NONNULL_END
