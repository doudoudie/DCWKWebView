//
//  DCWKWebViewHandle.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/22.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class DCWKWebView;

NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebViewHandle : NSObject

// 长按下载图片 用于保存
- (void)downLoadImageWithJS:(NSString *)imgJS wkWebView:(WKWebView *)wkWebView;

// 获取网页中所以的img标签对应的图片地址
+ (void)registerImageClick:(WKWebView *)wkWebView;

//判断地址是否包含自定义协议
+ (BOOL)containsCustomProtocolWithUrl:(NSString *)urlString;

+ (UIColor *)stringTOColor:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
