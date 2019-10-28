//
//  WKWebView+ExternalDelegate.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/11.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ExternalDelegate)

#pragma mark - ExternalNavigationDelegate

@property(nonatomic, weak) id mainNavigationDelegate;
@property(nonatomic, copy) NSArray *imgSrcs;

- (void)useExternalNavigationDelegate;
- (void)unUseExternalNavigationDelegate;
- (void)addExternalNavigationDelegate:(NSObject<WKNavigationDelegate> *)delegate;
- (void)removeExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate;
- (void)clearExternalNavigationDelegates;



@end

@protocol DCWKWebViewProtocol

@optional

/*
  回调WKWebView加载完的高度
  @param height webview的高度
 */
- (void)wkWebViewContentSizeHeight:(CGFloat)height;

//二维码识别出的内容
- (void)wkWebViewQrCodeRecognition:(NSString *)qrCodeUrl;

@end

NS_ASSUME_NONNULL_END
