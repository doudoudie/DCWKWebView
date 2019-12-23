//
//  AppDelegate+DCWKWebView.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/23.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "AppDelegate+DCWKWebView.h"
#import "DCWKWebViewCtrl.h"
#import "DCWKWebMnager.h"
#import "DCWKWebViewConfig.h"
#import "ArticleDetailViewController.h"

@implementation AppDelegate (DCWKWebView)

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([[url absoluteString] hasPrefix:@"dcwk"]) {
        NSLog(@"H5微信支付回调的地方 %s",__func__);
    }
    return YES;
}

- (void)setupDCWKWebView {
    DCWKWebViewConfig *config = [[DCWKWebViewConfig alloc] init];
    config.uaString = @"dcapp://";
    config.protocols = @[@"app://"];
    config.wxfqSchemes = @"dcwk.wxpay.wxutil.com"; //设置微信H5支付的回调schemes
    config.isOpenImagePreview = YES;
    
    [[DCWKWebMnager sharedInstance] setupDCWKWebView:config];
    
    [[DCWKWebMnager sharedInstance] registerHandler:@"testRegisrerJSBridge" responseHandler:^(NSInteger callbackId, NSString * _Nonnull handlerName, id  _Nonnull responseData) {
        NSLog(@"%@",handlerName);
    }];
    
}

- (void)wkWebViewQrCodeReader:(NSString *)qrCodeContent{
    NSLog(@"AppDelegate 二维码链接地址:%@",qrCodeContent);
    // 扫描的结果 也可以是一个自定义的协议
}

- (void)internalProtocolRouter:(NSString *)protocolPath {
    
    ArticleDetailViewController *ctrl = [[ArticleDetailViewController alloc] init];
    [self.rootViewController.navigationController pushViewController:ctrl animated:YES];
}

- (void)imagePreview:(NSString *)url {
    NSLog(@"image-Preview: %@",url);
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
