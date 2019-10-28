//
//  DCWKWebViewPool.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class DCWKWebView;


NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebViewPool : NSObject

+ (DCWKWebViewPool *)sharedInstance;

/**
 获取可复用的DCWKWebView
 
 @param delegate 可复用的DCWKWebView的 identifier
 @param configuration 可复用的DCWKWebView Configuration
 @return 可复用的DCWKWebView
 */
- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate
                                    configuration:(WKWebViewConfiguration *)configuration;

/**
 回收可复用的DCWKWebView
 
 @param wkWebView 可复用的wkWebView
 */
- (void)enqueueDCWKWebView:(DCWKWebView *)wkWebView;

@end

NS_ASSUME_NONNULL_END
