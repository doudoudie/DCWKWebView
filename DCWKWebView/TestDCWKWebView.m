//
//  TestDCWKWebView.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "TestDCWKWebView.h"
#import "DCWKWebView.h"
#import "DCWKWebMnager.h"
#import "DCWKWebViewHandle.h"
#import "DCJSBridgeHandler.h"
#import "WKWebView+DCExtension.h"

#import "ArticleDetailViewController.h"

@interface TestDCWKWebView ()<WKUIDelegate>
@property (nonatomic,strong) DCWKWebView *wkWebView;
@property (nonatomic,strong) DCJSBridgeHandler *jsBridgeHandler;
@end

@implementation TestDCWKWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.wkWebView];
    
    [self.jsBridgeHandler registerHandler:@"testRegisrerJSBridge" responseHandler:^(NSInteger callbackId, NSString * _Nonnull handlerName, id  _Nonnull responseData) {
        NSLog(@"%@",handlerName);
    }];
    
    [self.jsBridgeHandler registerHandler:@"testPOSTRequest" responseHandler:^(NSInteger callbackId, NSString * _Nonnull handlerName, id  _Nonnull responseData) {
        [self.wkWebView requestUrl:self.test_Url parameters:responseData];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注入JS" style:UIBarButtonItemStylePlain target:self action:@selector(evaluateJS)];
    
}

#pragma mark - UI控件懒加载
- (DCWKWebView *)wkWebView {
    if (!_wkWebView) {
        self.jsBridgeHandler = [[DCJSBridgeHandler alloc] initWithDelegate:self];
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.userContentController = [WKUserContentController new];
        [configuration.userContentController addScriptMessageHandler:self.jsBridgeHandler name:@"DCJSBridge"];
        
        _wkWebView = [[DCWKWebMnager sharedInstance] dequeueDCWKWebViewWithDelegate:self configuration:configuration];
        _wkWebView.frame = self.view.bounds;
        _wkWebView.UIDelegate = self;
        [_wkWebView requestUrl:self.test_Url];
    }
    return _wkWebView;
}

- (void)evaluateJS{
    
    static  NSString * const evaluateJS = @"function registerEvaluateJS(){\
    console.log(123);\
    var btn=document.getElementById('testEvaluateJS');\
    btn.onclick = function(){\
    console.log(456);\
    console.log('evaluateJS成功');\
        alert('evaluateJS成功')}\
    }";
    
    [self.wkWebView safeAsyncEvaluateJavaScriptString:evaluateJS];
    
    [self.wkWebView safeAsyncEvaluateJavaScriptString:@"registerEvaluateJS()"];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    
    NSString *absoluteString = [navigationAction.request.URL.absoluteString stringByRemovingPercentEncoding];
   
    NSLog(@"%@",absoluteString);
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSDictionary *param = message.body;
    NSString *functionName = [param objectForKey:@"functionName"];
    
    // 这里注释 是为了验证注册回调JSBridge 不影响
    if([functionName isEqualToString:@"testRegisrerJSBridge"]) return;
    
    if([functionName isEqualToString:@"testJSBridge"]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证JSBridge" message:param.description delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    completionHandler();
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"验证JS注入" message:message delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alertView show];
    
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
