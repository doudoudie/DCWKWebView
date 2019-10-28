//
//  DCWKWebView.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebView : WKWebView

@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,copy) NSArray *imgUrlArray;

- (instancetype)initWithFrame:(CGRect)frame;

// 发起DCWKWebView 的Request请求
- (void)postUrl:(NSURL *)url;

// 进回收池前 wkWebView清理
- (void)clearRequestEnterPool;

// 出回收池前 清理wkWebView 的BackForwardList，防止重用时展示上次页面
- (void)clearBackForwardList;

@end

NS_ASSUME_NONNULL_END
