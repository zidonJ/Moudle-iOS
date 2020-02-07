//
//  ViewController.m
//  Modularization
//
//  Created by zidonj on 2019/2/13.
//  Copyright © 2019 langlib. All rights reserved.
//

#import "ViewController.h"
#import <JLRoutes.h>
#import <objc/runtime.h>
#import "ZDRouter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[ZDRoutes routesForScheme:@"MAVC"] addRoute:@"NaviPush/:controller/:controller1/:controller2" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        UIViewController *v = [[NSClassFromString(parameters[@"controller"]) alloc] init];
        [v setValueWithParameter:parameters];
        [self.navigationController pushViewController:v animated:YES];
        return true;
    }];
    
    [[ZDRoutes routesForScheme:@"MBVC"] addRoute:@"/NaviPush/:controller" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        UIViewController *v = [[NSClassFromString(parameters[@"controller"]) alloc] init];
        [v setValueWithParameter:parameters];
        [self.navigationController pushViewController:v animated:YES];
        return true;
    }];
    
    [[ZDRoutes routesForScheme:@"MCVC"] addRoute:@"/NaviPush/:controller" handler:^BOOL(NSDictionary<NSString *,id> * _Nonnull parameters) {
        UIViewController *v = [[NSClassFromString(parameters[@"controller"]) alloc] init];
        [v setValueWithParameter:parameters];
        [self.navigationController pushViewController:v animated:YES];
        return true;
    }];
    
}

- (IBAction)jumpA:(id)sender {
    NSString *customURL = @"MAVC://NaviPush/MAController/MBController/MCController?userId=99999&age=18";
    [[ZDRoutes routesForScheme:@"MAVC"] routeURL:[NSURL URLWithString:customURL]
                                  withParameters:@{@"dict":@{@"test":@"这是一段经典的旋律"}}];
}
     
- (IBAction)jumpB:(id)sender {
    NSString *customURL = @"MBVC://NaviPush/MBController?userId=99999&age=18";
    [[ZDRoutes routesForScheme:@"MBVC"] routeURL:[NSURL URLWithString:customURL]];
}
     
- (IBAction)jumpC:(id)sender {
    NSString *customURL = @"MCVC://NaviPush/MCController?userId=99999&age=18";
    [[ZDRoutes routesForScheme:@"MCVC"] routeURL:[NSURL URLWithString:customURL]];
}

@end
