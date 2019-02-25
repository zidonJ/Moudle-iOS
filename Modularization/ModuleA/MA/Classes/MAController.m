//
//  MAController.m
//  MA
//
//  Created by zidonj on 2019/2/13.
//  Copyright © 2019 langlib. All rights reserved.
//

#import "MAController.h"

@interface MAController ()

@end

@implementation MAController

#pragma mark -- cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _uiConfig];
    NSLog(@"%@--%@\n%@",self.userId,self.age,self.dict);
}

#pragma mark -- UIConfig

- (void)_uiConfig {

    self.title = @"模块A";
    self.view.backgroundColor = [UIColor whiteColor];
    [self _layoutContrains];
}

#pragma mark -- Public Method

#pragma mark -- Private Method

#pragma mark - Action

#pragma mark - KVO

#pragma mark - noticfication

#pragma mark -- Protocols

#pragma mark -- UITableViewDelegate

#pragma mark -- UITableViewDataSource

#pragma mark -- http request

#pragma mark -- layoutContrains

- (void)_layoutContrains {
    
    
}

#pragma mark -- Setters

#pragma mark -- Getters

- (void)dealloc {
    NSLog(@"%@-释放",[self class]);
}

@end
