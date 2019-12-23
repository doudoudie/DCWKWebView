//
//  DCWKWebMnager.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "DCJSBridgeHandler.h"
#define macro
@class DCWKWebView,DCWKWebViewConfig;

NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebMnager : NSObject<WKNavigationDelegate>

+ (instancetype)sharedInstance;

- (void)setupDCWKWebView:(DCWKWebViewConfig *)config;

/**
 获得一个可复用的DCWKWebView
 
 @param delegate webview的自定义identifier
 */
- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate;

- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate configuration:(WKWebViewConfiguration *)configuration;

/**
 回收可复用的WKWebView
 @param wkWebView 可复用的wkWebView
 */
- (void)enqueueDCWKWebView:(DCWKWebView *)wkWebView;

- (void)registerHandler:(NSString*)handlerName responseHandler:(DCBridgeResponseHandler)handler;

- (void)removeHandler:(NSString*)handlerName;

@end

NS_ASSUME_NONNULL_END
