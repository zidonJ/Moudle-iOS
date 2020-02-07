//
//  NSObject+ZDRouter.h
//  Modularization
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 langlib. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZDRouter)

- (void)setValueWithParameter:(NSDictionary<NSString *,NSString *> *)parameters;

@end

NS_ASSUME_NONNULL_END
