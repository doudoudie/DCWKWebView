//
//  WKWebView+ExternalDelegate.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/11.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "WKWebView+ExternalDelegate.h"
#import "WKWebView+DCExtension.h"
#import "DCWKWebViewHandle.h"

#import <objc/runtime.h>

#define KDefaultWebHeight 44
#define kGetContentSizeHeightJS @"Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)"

@interface DCWKWebViewDelegateHandle : NSObject<WKNavigationDelegate>

@property(nonatomic, weak, readwrite) id mainNavigationDelegate;
@property(nonatomic, strong, readwrite) NSHashTable *weakNavigationDelegates;

@property(nonatomic, assign, readwrite) BOOL isUseExternalDelegate;
@property(nonatomic, strong, readwrite) DCWKWebViewDelegateHandle *delegateHandle ;
@property(nonatomic, strong, readwrite) id<WKNavigationDelegate> originalNavigationDelegate;

@end

@implementation DCWKWebViewDelegateHandle

- (instancetype)init {
    self = [super init];
    if (self) {
        _weakNavigationDelegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

#pragma mark -
- (void)addNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    if (delegate && ![self.weakNavigationDelegates.allObjects containsObject:delegate]) {
        [_weakNavigationDelegates addObject:delegate];
    }
}
- (void)removeNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    if (delegate) {
        [_weakNavigationDelegates removeObject:delegate];
    }
}
- (BOOL)containNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    return delegate ? [_weakNavigationDelegates.allObjects containsObject:delegate] : NO;
}
- (void)removeAllNavigationDelegate {
    for (id<WKNavigationDelegate> delegate in _weakNavigationDelegates) {
        [_weakNavigationDelegates removeObject:delegate];
    }
}


#pragma mark -

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    __block BOOL isResponse = NO;
    
    NSString *absoluteString = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    
    if ([absoluteString hasPrefix:@"tel://"] || [absoluteString hasPrefix:@"telephone://"]) {
        NSURL *URL = navigationAction.request.URL;
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt:%@", resourceSpecifier];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        NSURL *URL = navigationAction.request.URL;
        [[UIApplication sharedApplication] openURL:URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        isResponse = YES;
    } else {
        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
                isResponse = YES;
            }
        };
    }
    
    if (!isResponse) {
        // for webview reuse
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didCommitNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didCommitNavigation:navigation];
        }
    };
}



- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didStartProvisionalNavigation:navigation];
        }
    };
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    // 网页上所有的img标签图片地址添加click事件
    [DCWKWebViewHandle registerImageClick:webView];
    
    if ([mainDelegate respondsToSelector:@selector(wkWebViewContentSizeHeight:)]) {
        [self handleContentSizeHeight:webView];
    }
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFinishNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFinishNavigation:navigation];
        }
    };
}

- (void)handleContentSizeHeight:(WKWebView *)webView {
    [webView safeAsyncEvaluateJavaScriptString:kGetContentSizeHeightJS completionBlock:^(NSObject * _Nonnull result) {
        
        CGFloat webHeight = [[NSString stringWithFormat:@"%@",result] doubleValue];
        
        if ([self.mainNavigationDelegate respondsToSelector:@selector(wkWebViewContentSizeHeight:)]) {
            [self.mainNavigationDelegate wkWebViewContentSizeHeight:webHeight];
        }
    }];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailNavigation:navigation withError:error];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFailNavigation:navigation withError:error];
        }
    };
}

- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
        }
    };
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 9.0, *)) {
        [webView reload]; //解决白屏
        id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
        
        if ([mainDelegate respondsToSelector:_cmd]) {
            [mainDelegate webViewWebContentProcessDidTerminate:webView];
        }
        
        for (id delegate in self.weakNavigationDelegates.allObjects) {
            if ([delegate respondsToSelector:_cmd]) {
                [delegate webViewWebContentProcessDidTerminate:webView];
            }
        };
    }
#endif
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    id<WKNavigationDelegate> mainDelegate = self.mainNavigationDelegate;
    
    if ([mainDelegate respondsToSelector:_cmd]) {
        [mainDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
    
    for (id delegate in self.weakNavigationDelegates.allObjects) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
        }
    };
}

@end

#pragma mark - ExternalDelegate in under

@interface WKWebView()
@property(nonatomic, assign, readwrite) BOOL isUseExternalDelegate;
@property(nonatomic, strong, readwrite) DCWKWebViewDelegateHandle *delegateHandle;
@property(nonatomic, weak, readwrite) id<WKNavigationDelegate> originalNavigationDelegate;
@property(nonatomic, copy,readwrite) NSArray *imgSrcs;
@end

@implementation WKWebView (ExternalDelegate)

#pragma mark - ExternalNavigationDelegate property

- (void)setImgSrcs:(NSArray *)imgSrcs
{
    objc_setAssociatedObject(self, @"imgSrcs", imgSrcs, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)getImgSrcs
{
    return objc_getAssociatedObject(self, @"imgSrcs");
}

- (void)setIsUseExternalDelegate:(BOOL)isUseExternalDelegate{
    objc_setAssociatedObject(self, @"isUseExternalDelegate", @(isUseExternalDelegate), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)isUseExternalDelegate{
    NSNumber *isUseExternalDelegate = objc_getAssociatedObject(self, @"isUseExternalDelegate");
    return isUseExternalDelegate.boolValue;
}

- (void)setDelegateDispatcher:(DCWKWebViewDelegateHandle *)delegateHandle{
    objc_setAssociatedObject(self, @"delegateHandle", delegateHandle, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (DCWKWebViewDelegateHandle *)delegateHandle{
    return objc_getAssociatedObject(self, @"delegateHandle");
}

- (void)setOriginalNavigationDelegate:(id<WKNavigationDelegate>)originalNavigationDelegate{
    objc_setAssociatedObject(self, @"originalNavigationDelegate", originalNavigationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (id<WKNavigationDelegate>)originalNavigationDelegate{
    return objc_getAssociatedObject(self, @"originalNavigationDelegate");
}

- (void)setMainNavigationDelegate:(id)originaDelegate {
    [self delegateHandle].mainNavigationDelegate = originaDelegate;
}

- (id)mainNavigationDelegate {
    return [self delegateHandle].mainNavigationDelegate;
}

#pragma mark - ExternalNavigationDelegate

- (void)useExternalNavigationDelegate {
    if ([self isUseExternalDelegate] && [self delegateHandle]) {
        return;
    }
    
    [self setDelegateDispatcher:[[DCWKWebViewDelegateHandle alloc] init]];
    [self setOriginalNavigationDelegate:self.navigationDelegate];
    
    [self setNavigationDelegate:[self delegateHandle]];
    [[self delegateHandle] addNavigationDelegate:[self originalNavigationDelegate]];
    
    [self setIsUseExternalDelegate:YES];
}

- (void)unUseExternalNavigationDelegate{
    [self setNavigationDelegate:[self originalNavigationDelegate]];
    [self setDelegateDispatcher:nil];
    [self setIsUseExternalDelegate:NO];
}

- (void)addExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    [[self delegateHandle] addNavigationDelegate:delegate];
}

- (void)removeExternalNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    [[self delegateHandle] removeNavigationDelegate:delegate];
}

- (void)clearExternalNavigationDelegates {
    [[self delegateHandle] removeAllNavigationDelegate];
}

@end
