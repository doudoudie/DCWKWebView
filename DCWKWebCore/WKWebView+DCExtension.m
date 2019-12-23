//
//  WKWebView+DCExtension.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "WKWebView+DCExtension.h"
#import "WKWebView+ExternalDelegate.h"
#import <objc/runtime.h>

@interface WKWebView ()
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSString *> *cookieDic;

@end

@implementation WKWebView (DCExtension)

#pragma mark - UA

- (void)ConfigDCWKWebViewUA:(NSString *)uaString completionBlock:(void(^)(BOOL success))block{
    
    if (!uaString || uaString.length <= 0) {
        NSLog(@"DCWKWebViewUA config with invalid string");
        return;
    }
    
    [self evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSString *newUserAgent = [NSString stringWithFormat:@"%@/%@",result,uaString];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"userAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        if(block)block(YES);
        NSLog(@"DCWKWebView navigator.userAgent 修改成功!");
    }];
}

#pragma mark - evaluate js

/**
 执行js，retain self 防止crash
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script {
    [self safeAsyncEvaluateJavaScriptString:script completionBlock:nil];
}

/**
 执行js，retain self 防止crash
 明确result类型，null -> string, 返回NSObject类型
 */
- (void)safeAsyncEvaluateJavaScriptString:(NSString *)script completionBlock:(nullable DCWKWebViewJSCompletionBlock)block {
    if (!script || script.length <= 0) {
        NSLog(@"invalid script");
        if (block) {
            block(@"");
        }
        return;
    }
    
    [self evaluateJavaScript:script
           completionHandler:^(id result, NSError *_Nullable error) {
               //retain self
               __unused __attribute__((objc_ownership(strong))) __typeof__(self) self_retain_ = self;
               NSObject *resultObj = @"";
               if (!error) {
                   if (block) {
                       if (!result || [result isKindOfClass:[NSNull class]]) {
                           resultObj = nil;
                       } else if ([result isKindOfClass:[NSNumber class]]) {
                           resultObj = ((NSNumber *)result).stringValue;
                       } else if ([result isKindOfClass:[NSObject class]]){
                           resultObj = (NSObject *)result;
                       } else {
                           resultObj = nil;
                           NSLog(@"evaluate js return type:%@, js:%@",
                                       NSStringFromClass([result class]),
                                       script);
                       }
                       if (block) {
                           block(resultObj);
                       }
                   }
               } else {
                   resultObj = nil;
                   NSLog(@"evaluate js Error : %@ %@", error.description, script);
                   if (block) {
                       block(resultObj);
                   }
               }
           }];
}

#pragma mark - Cookies

- (void)setCookieDic:(NSMutableDictionary *)cookieDic {
    objc_setAssociatedObject(self, @selector(setCookieDic:), cookieDic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)cookieDic {
    return objc_getAssociatedObject(self, @selector(setCookieDic:));;
}
/**
 手动设置cookies
 */
- (void)setCookieWithName:(NSString *)name
                    value:(NSString *)value
                   domain:(NSString *)domain
                     path:(NSString *)path
              expiresDate:(NSDate *)expiresDate
          completionBlock:(DCWKWebViewJSCompletionBlock)completionBlock {
    
    if (!name || name.length <= 0) {
        return;
    }
    
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    [cookieScript appendFormat:@"document.cookie='%@=%@;", name, value];
    if (domain || domain.length > 0) {
        [cookieScript appendFormat:@"domain=%@;", domain];
    }
    if (path || path.length > 0) {
        [cookieScript appendFormat:@"path=%@;", path];
    }
    
    if (!self.cookieDic) {
        self.cookieDic = @{}.mutableCopy;
    }
    
    [[self cookieDic] setValue:cookieScript.copy forKey:name];
    
    if (expiresDate && [expiresDate timeIntervalSince1970] != 0) {
        [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());", @(([expiresDate timeIntervalSince1970]) * 1000)];
    }else{
        [cookieScript appendFormat:@"'"];
    }
    [cookieScript appendFormat:@"\n"];
    
    [self safeAsyncEvaluateJavaScriptString:cookieScript.copy completionBlock:completionBlock];
}

/**
 删除相应name的cookie
 */
- (void)deleteCookiesWithName:(NSString *)name completionBlock:(nullable DCWKWebViewJSCompletionBlock)completionBlock {
    if (!name || name.length <= 0) {
        return;
    }
    
    if (![[[self cookieDic] allKeys] containsObject:name]) {
        return;
    }
    
    NSMutableString *cookieScript = [[NSMutableString alloc] init];
    
    [cookieScript appendString:[[self cookieDic] objectForKey:name]];
    [cookieScript appendFormat:@"expires='+(new Date(%@).toUTCString());\n", @(0)];
    
    [[self cookieDic] removeObjectForKey:name];
    [self safeAsyncEvaluateJavaScriptString:cookieScript.copy completionBlock:completionBlock];
}

/**
 获取全部通过setCookieWithName注入的cookieName
 */
- (NSSet<NSString *> *)getAllCustomCookiesName {
    return [[self cookieDic] allKeys].copy;
}

/**
 删除所有通过setCookieWithName注入的cookie
 */
- (void)deleteAllCustomCookies {
    for (NSString *cookieName in [[self cookieDic] allKeys]) {
        [self deleteCookiesWithName:cookieName completionBlock:nil];
    }
}

@end
