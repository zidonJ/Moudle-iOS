//
//  ModularizationCenter.m
//  Modularization
//
//  Created by zidonj on 2020/2/7.
//  Copyright © 2020 langlib. All rights reserved.
//

#import "ModularizationCenter.h"
#import <JLRoutes/JLRoutes.h>

static ModularizationCenter *_instance = nil;

@interface ModularizationCenter ()

@end

@implementation ModularizationCenter

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark -- super --
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

@end
