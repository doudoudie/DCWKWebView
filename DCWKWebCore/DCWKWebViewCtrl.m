//
//  DCWKWebViewCtrl.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebViewCtrl.h"
#import "DCWKWebMnager.h"
#import "DCWKWebView.h"
#import "WKWebView+ExternalDelegate.h"
#import "WKWebView+DCExtension.h"
#import "DCWKWebViewToolBar.h"
#import "DCWKWebViewMacro.h"
#import "DCWKWebViewHandle.h"
#import "DCJSBridgeHandler.h"
#import "DCWKWebViewConfig.h"

@interface DCWKWebViewCtrl ()<WKNavigationDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    float lastContentOffset;
}
@property (nonatomic,strong) DCWKWebView *wkWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic,strong) DCWKWebViewToolBar *toolBar;
@property (nonatomic,assign) BOOL showToolBarStatus;
@property (nonatomic,strong) DCJSBridgeHandler *bridgeHandle;

@end

@implementation DCWKWebViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.toolBar];
    
    //进度条
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, SafeTopHeight, [[UIScreen mainScreen] bounds].size.width, 1)];
    self.progressView.trackTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [DCWKWebViewHandle stringTOColor:@"#4BA7F7"];
    [self.view addSubview:self.progressView];
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.wkWebView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.wkWebView.title == nil) { //防止白屏
        [self.wkWebView reload];
    }
}

#pragma mark - UI控件懒加载
- (DCWKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[DCWKWebMnager sharedInstance] dequeueDCWKWebViewWithDelegate:self];
        _wkWebView.frame = self.view.bounds;
        _wkWebView.scrollView.delegate = self;
        [_wkWebView requestUrl:self.url];
        
    }
    return _wkWebView;
}

- (DCWKWebViewToolBar *)toolBar {
    if(!_toolBar){
        _toolBar = [[DCWKWebViewToolBar alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 60 + SafeBottomHeight) withWkWebView:self.wkWebView];
        _toolBar.hidden = YES;
    }
    
    return _toolBar;
}

#pragma mark - ToolBar的现实和隐藏控制
- (void)showToolBar {
    self.toolBar.hidden = NO;
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.toolBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60 - SafeBottomHeight, [UIScreen mainScreen].bounds.size.width, 60 + SafeBottomHeight);
    } completion:^(BOOL finished) {
        weakSelf.wkWebView.frame = CGRectMake(weakSelf.wkWebView.frame.origin.x, weakSelf.wkWebView.frame.origin.y, weakSelf.wkWebView.frame.size.width, [UIScreen mainScreen].bounds.size.height - 60);
    }];
}

- (void)hideToolBar {
    __weak typeof (self)weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.toolBar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 60 + SafeBottomHeight);
    } completion:^(BOOL finished) {
        weakSelf.toolBar.hidden = YES;
        weakSelf.wkWebView.frame = CGRectMake(weakSelf.wkWebView.frame.origin.x, weakSelf.wkWebView.frame.origin.y, weakSelf.wkWebView.frame.size.width, [UIScreen mainScreen].bounds.size.height);
    }];
}


#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    webView.scrollView.delegate = self;
    NSLog(@"开始加载网页");
    NSString *url  = webView.URL.absoluteString;
    NSLog(@"%@",url);
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    webView.scrollView.delegate = nil;
    self.progressView.hidden = YES;
    NSLog(@"加载失败");
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    NSLog(@"加载完成");
    //禁用 页面元素选择
    [webView safeAsyncEvaluateJavaScriptString:@"document.documentElement.style.webkitUserSelect='none';"];
    //禁用 长按弹出ActionSheet
    [webView safeAsyncEvaluateJavaScriptString:@"document.documentElement.style.webkitTouchCallout='none';"];
    
    if(webView.canGoBack || webView.canGoForward) {
        self.showToolBarStatus = YES;
        [self showToolBar];
    }
    
    [self.toolBar refreshButtonsSataus];
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    // navigationAction.navigationType : WKNavigationTypeLinkActivated 是超链接类型
    
    NSString *absoluteString = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
    
    if([DCWKWebViewHandle containsInternalProtocolWithUrl:absoluteString]){
        id<UIApplicationDelegate> applicateDelegate = (id)[UIApplication sharedApplication].delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL sel = NSSelectorFromString(@"internalProtocolRouter:");
        if ([applicateDelegate respondsToSelector:sel]) {
            [applicateDelegate performSelector:sel withObject:absoluteString];
        }
#pragma clang diagnostic pop
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if([absoluteString hasPrefix:@"image-preview://"]){
        NSLog(@"图片预览 %@",absoluteString);
        id<UIApplicationDelegate> applicateDelegate = (id)[UIApplication sharedApplication].delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        SEL sel = NSSelectorFromString(@"imagePreview:");
        if ([applicateDelegate respondsToSelector:sel]) {
            [applicateDelegate performSelector:sel withObject:absoluteString];
        }
#pragma clang diagnostic pop
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    else if ([absoluteString hasPrefix:@"https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"] && ![absoluteString hasSuffix:[NSString stringWithFormat:@"redirect_url=%@://",[DCWKWebViewConfig sharedInstance].wxfqSchemes]]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        
        [self request_redirect_url:absoluteString request:navigationAction.request];
        return;
    }
    else if([absoluteString containsString:@"weixin://wap/pay?"]) {
        //判断是否为支付链接，可能会加载多个链接，只有包含"weixin://wap/pay?"才是可以跳转微信APP的链接，
        // 跳转微信进行支付
        NSURL *url = [NSURL URLWithString:absoluteString];
        if (@available(iOS 10.0, *)) { // 10.0以上的版本
            if([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:nil];
                [webView goBack];
            }
        } else { // 10.0以下的版本
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:)]) {
                [[UIApplication sharedApplication] openURL:url];
                [webView goBack];
            }
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    // 刷新ToolBar的状态
    [self.toolBar refreshButtonsSataus];
    
    if(webView.canGoBack) {
        self.showToolBarStatus = YES;
        [self showToolBar];
    }
}

#pragma mark - scrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if(!self.showToolBarStatus) return;
    if (lastContentOffset < scrollView.contentOffset.y) {
        [self hideToolBar];
    }else{
        [self showToolBar];
    }
}

#pragma mark - wkWebViewContentSize 高度的回调
- (void)wkWebViewContentSizeHeight:(CGFloat)height {
    
}

#pragma mark - 二维码链接地址
- (void)wkWebViewQrCodeRecognition:(NSString *)qrCodeUrl{
    NSLog(@"二维码链接地址:%@",qrCodeUrl);
    
    DCWKWebViewCtrl *ctrl = [DCWKWebViewCtrl new];
    ctrl.url = [NSURL URLWithString:qrCodeUrl];
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark - KVO 监听wkwebview的title以及加载进度
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wkWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
            }];
        }
    }else if ([keyPath isEqualToString:@"title"]) {
        if (object == self.wkWebView){
            if(self.wkWebView.title.length > 16){
                self.title = [NSString stringWithFormat:@"%@...",[self.wkWebView.title substringToIndex:16]];
            }else {
                self.title = self.wkWebView.title;
            }
        }else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

 #pragma mark - 微信支付新发起一个请求
- (void)request_redirect_url:(NSString *)absoluteString request:(NSURLRequest *)request{
    //The string Scheme_Domain must be configured by wechat background. It must be your company first domin. You also should configure "URL types" in the Info.plist file.
    
    // 1. If the url contain "redirect_url" : We need to remember it to use our scheme replace it.
    // 2. If the url not contain "redirect_url" , We should add it so that we will could jump to our app.
    //  Note : 2. if the redirect_url is not last string, you should use correct strategy, because the redirect_url's value may contain some "&" special character so that my cut method may be incorrect.
    static NSString *endPayRedirectURL = nil;
    NSString *redirectUrl = nil;
    if ([absoluteString containsString:@"redirect_url="]) {
        NSRange redirectRange = [absoluteString rangeOfString:@"redirect_url"];
        endPayRedirectURL =  [absoluteString substringFromIndex:redirectRange.location+redirectRange.length+1];
        redirectUrl = [[absoluteString substringToIndex:redirectRange.location] stringByAppendingString:[NSString stringWithFormat:@"redirect_url=%@://",[DCWKWebViewConfig sharedInstance].wxfqSchemes]];
    }else {
        redirectUrl = [absoluteString stringByAppendingString:[NSString stringWithFormat:@"&redirect_url=%@://",[DCWKWebViewConfig sharedInstance].wxfqSchemes]];
    }
    
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:redirectUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
    newRequest.URL = [NSURL URLWithString:redirectUrl];
    [self.wkWebView loadRequest:newRequest];
}

#pragma mark - dealloc
- (void)dealloc {
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
    //[self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"DCJSBridge"];
    [[DCWKWebMnager sharedInstance] enqueueDCWKWebView:self.wkWebView];
    self.wkWebView = nil;
    self.toolBar = nil;
    NSLog(@"dealloc DCWKWebViewController");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
