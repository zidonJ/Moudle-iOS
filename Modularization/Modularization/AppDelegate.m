//
//  AppDelegate.m
//  Modularization
//
//  Created by zidonj on 2019/2/13.
//  Copyright © 2019 langlib. All rights reserved.
//

#import "AppDelegate.h"
#import "JLRoutes.h"
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

- (void)paramToVc:(UIViewController *)v param:(NSDictionary<NSString *,NSString *> *)parameters {
    //runtime将参数传递至需要跳转的控制器
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(v.class , &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *key = [NSString stringWithUTF8String:property_getName(property)];
        NSString *param = parameters[key];
        if (param != nil) {
            [v setValue:param forKey:key];
        }
    }
}

- (UIViewController *)currentViewController {
    
    UIViewController *currVC = nil;
    UIViewController *Rootvc = self.window.rootViewController ;
    do {
        if ([Rootvc isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)Rootvc;
            UIViewController *v = [nav.viewControllers lastObject];
            currVC = v;
            Rootvc = v.presentedViewController;
            continue;
        }else if([Rootvc isKindOfClass:[UITabBarController class]]){
            UITabBarController * tabVC = (UITabBarController *)Rootvc;
            currVC = tabVC;
            Rootvc = [tabVC.viewControllers objectAtIndex:tabVC.selectedIndex];
            continue;
        }
    } while (Rootvc!=nil);
    
    return currVC;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    [[BeeHive shareInstance].context.openURLItem setOpenURL:url];
    [[BHModuleManager sharedManager] triggerEvent:BHMOpenURLEvent];
    
    NSString *urlSchemeStr = [[url scheme] lowercaseString];
    if ([urlSchemeStr isEqualToString:@"mavc"]) {
        return [[JLRoutes routesForScheme:@"MAVC"] routeURL:url withParameters:@{@"dict":@{@"test":@"这是一段经典的旋律"}}];
    } else if ([urlSchemeStr isEqualToString:@"mbvc"]) {
        return [[JLRoutes routesForScheme:@"MBVC"] routeURL:url];
    }else if ([urlSchemeStr isEqualToString:@"mcvc"]) {
        return [[JLRoutes routesForScheme:@"MCVC"] routeURL:url];
    }
    return [JLRoutes routeURL:url];
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
