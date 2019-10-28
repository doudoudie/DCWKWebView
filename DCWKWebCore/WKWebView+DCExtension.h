//
//  WKWebView+DCExtension.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DCWKWebViewJSCompletionBlock)(NSObject *result);

@interface WKWebView (DCExtension)

#pragma mark - UA

/**
  配置DCWKWebView 默认的UA
 */
- (void)ConfigDCWKWebViewUA:(NSString *)uaString completionBlock:(void(^)(BOOL success))block;

#pragma mark - Evaluate js

/**
 执行js，retain self 防止crash
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script;

/**
 执行js，retain self 防止crash
 明确result类型，null -> string, 返回NSObject类型
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(nullable DCWKWebViewJSCompletionBlock)block;

#pragma mark - Cookies

/**
 手动设置cookies
 */
- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(nullable DCWKWebViewJSCompletionBlock)completionBlock;

/**
 删除相应name的cookie
 */
- (void)deleteCookiesWithName:(NSString *)name completionBlock:(nullable DCWKWebViewJSCompletionBlock)completionBlock;

/**
 获取全部通过setCookieWithName注入的cookieName
 */
- (NSSet<NSString *> *)getAllCustomCookiesName;

/**
 删除所有通过setCookieWithName注入的cookie
 */
- (void)deleteAllCustomCookies;


@end

NS_ASSUME_NONNULL_END
