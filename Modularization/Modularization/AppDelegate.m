//
//  AppDelegate.m
//  Modularization
//
//  Created by zidonj on 2019/2/13.
//  Copyright © 2019 langlib. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/runtime.h>
#import <BeeHive.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [[BHModuleManager sharedManager] triggerEvent:BHMSetupEvent];
    [[BHModuleManager sharedManager] triggerEvent:BHMInitEvent];
    /// 配置 BeeHive 上下文
    [[BeeHive shareInstance] setContext:[BHContext shareInstance]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[BHModuleManager sharedManager] triggerEvent:BHMSplashEvent];
    });
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    [[BeeHive shareInstance].context.openURLItem setOpenURL:url];
    [[BHModuleManager sharedManager] triggerEvent:BHMOpenURLEvent];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[BHModuleManager sharedManager] triggerEvent:BHMWillResignActiveEvent];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[BHModuleManager sharedManager] triggerEvent:BHMDidEnterBackgroundEvent];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[BHModuleManager sharedManager] triggerEvent:BHMWillEnterForegroundEvent];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[BHModuleManager sharedManager] triggerEvent:BHMDidBecomeActiveEvent];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[BHModuleManager sharedManager] triggerEvent:BHMWillTerminateEvent];
}


@end
