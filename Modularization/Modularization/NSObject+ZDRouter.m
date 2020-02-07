//
//  NSObject+ZDRouter.m
//  Modularization
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 langlib. All rights reserved.
//

#import "NSObject+ZDRouter.h"
#import <objc/runtime.h>

@implementation NSObject (ZDRouter)

- (void)setValueWithParameter:(NSDictionary<NSString *,NSString *> *)parameters {
    //runtime将参数传递至需要跳转的控制器
    
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class] , &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        NSString *param = parameters[key];
        if (param != nil) {
            [self setValue:param forKey:key];
        }
    }
}

@end
