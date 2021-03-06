//
//  DCWKWebMnager.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebMnager.h"
#import "DCWKWebView.h"
#import "DCJSBridgeHandler.h"
#import "DCWKWebViewPool.h"
#import "WKWebView+DCExtension.h"
#import "DCWKWebViewConfig.h"
#import "DCWKWebViewHandle.h"

@interface DCWKWebMnager ()
@property (nonatomic,strong) DCJSBridgeHandler *bridgeHandle;
@end

@implementation DCWKWebMnager

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DCWKWebMnager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    if(self = [super init]){
        _bridgeHandle = [[DCJSBridgeHandler alloc] initWithDelegate:self];
    }
    return self;
}

- (void)setupDCWKWebView:(nonnull DCWKWebViewConfig *)config{
    [DCWKWebViewConfig sharedInstance].protocols = config.protocols;
    [DCWKWebViewConfig sharedInstance].wxfqSchemes = config.wxfqSchemes;
    [DCWKWebViewConfig sharedInstance].isOpenImagePreview = config.isOpenImagePreview;
    __weak typeof (self)weakSelf = self;
    // 默认缓存框架内的 WKWebViewController
    DCWKWebView *tempWebView = [self dequeueDCWKWebViewWithDelegate:@"DCWKWebViewCtrl"];
    //全局设置UserAgent
    [tempWebView ConfigDCWKWebViewUA:config.uaString completionBlock:^(BOOL success) {
       [weakSelf enqueueDCWKWebView:tempWebView];
    }];
}

- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate{
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    [configuration.userContentController addScriptMessageHandler:self.bridgeHandle name:@"DCJSBridge"];
    
    return [self dequeueDCWKWebViewWithDelegate:delegate configuration:configuration];
}

- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate configuration:(WKWebViewConfiguration *)configuration {
    
    return [[DCWKWebViewPool sharedInstance] dequeueDCWKWebViewWithDelegate:delegate configuration:configuration];
}

/**
 回收可复用的WKWebView
 @param wkWebView 可复用的wkWebView
 */
- (void)enqueueDCWKWebView:(DCWKWebView *)wkWebView {
    [[DCWKWebViewPool sharedInstance] enqueueDCWKWebView:wkWebView];
}

- (void)registerHandler:(NSString*)handlerName responseHandler:(DCBridgeResponseHandler)handler{
    [self.bridgeHandle registerHandler:handlerName responseHandler:handler];
}

- (void)removeHandler:(NSString*)handlerName {
    [self.bridgeHandle removeHandler:handlerName];
}

- (void)dealloc
{
    NSLog(@"dealloc DCWKWebMnager");
}

@end
