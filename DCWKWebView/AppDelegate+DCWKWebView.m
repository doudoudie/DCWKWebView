//
//  AppDelegate+DCWKWebView.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/23.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "AppDelegate+DCWKWebView.h"
#import "DCWKWebViewCtrl.h"

@implementation AppDelegate (DCWKWebView)

- (void)wkWebViewQrCodeRecognition:(NSString *)qrCodeUrl{
    NSLog(@"AppDelegate 二维码链接地址:%@",qrCodeUrl);
}

- (void)customProtocolRouter:(NSString *)protocolPath {
    DCWKWebViewCtrl *ctrl = [DCWKWebViewCtrl new];
    ctrl.url = [NSURL URLWithString:protocolPath];
    [[self rootViewController].navigationController pushViewController:ctrl animated:YES];
}

- (UIViewController *)rootViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)vc;
        vc = tabVC.selectedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)vc;
        vc = nc.visibleViewController;
    }
    return vc;
}

@end
