//
//  ViewController.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "ViewController.h"
#import "DCWKWebViewCtrl.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳转" style:UIBarButtonItemStylePlain target:self action:@selector(pushToWKWebView)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"跳一跳" style:UIBarButtonItemStylePlain target:self action:@selector(pushToWKWebViewA)];
    
}


- (void)pushToWKWebView {
    DCWKWebViewCtrl *ctrl = [DCWKWebViewCtrl new];
    ctrl.url = [NSURL URLWithString:@"http://192.168.2.173:8081/"];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)pushToWKWebViewA {
    DCWKWebViewCtrl *ctrl = [DCWKWebViewCtrl new];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"];
    
    //NSString *url = @"https://mp.weixin.qq.com/s/1ElHPKGMZUDYdnF8CJiSWA";
    //NSString *str = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    ctrl.url = url; //[NSURL URLWithString:str];
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
