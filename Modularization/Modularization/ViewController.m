//
//  ViewController.m
//  Modularization
//
//  Created by zidonj on 2019/2/13.
//  Copyright © 2019 langlib. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)jumpA:(id)sender {
    NSString *customURL = @"MAVC://NaviPush/MAController?userId=99999&age=18";
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:customURL] options:@{} completionHandler:nil];
}
- (IBAction)jumpB:(id)sender {
    NSString *customURL = @"MBVC://NaviPush/MBController?userId=99999&age=18";
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:customURL] options:@{} completionHandler:nil];
}
- (IBAction)jumpC:(id)sender {
    NSString *customURL = @"MCVC://NaviPush/MCController?userId=99999&age=18";
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:customURL] options:@{} completionHandler:nil];
}

@end
