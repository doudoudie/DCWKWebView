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

- (void)wkWebViewQrCodeRecognition:(NSString *)qrCodeUrl;

- (void)customProtocolRouter:(NSString *)protocolPath;

@end

NS_ASSUME_NONNULL_END
