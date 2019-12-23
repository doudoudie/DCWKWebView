//
//  AppDelegate+DCWKWebView.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/23.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "AppDelegate.h"
#import "WKWebView+ExternalDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (DCWKWebView)

- (void)setupDCWKWebView;

// 长按识别二维码
- (void)wkWebViewQrCodeReader:(NSString *)qrCodeContent;

// 内部协议跳转
- (void)internalProtocolRouter:(NSString *)protocolPath;

// 点击图片预览
- (void)imagePreview:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
