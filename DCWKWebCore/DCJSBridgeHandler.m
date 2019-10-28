//
//  DCJSCallBack.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCJSBridgeHandler.h"

@interface DCJSBridgeHandler ()
@property (strong, nonatomic) NSMutableDictionary* messageHandlers;
@property (nonatomic, weak) id delegate;
@end

@implementation DCJSBridgeHandler

#pragma mark - WKScriptMessageHandler Delegate

-(instancetype)initWithDelegate:(id)delegate{
    if (self = [super init]) {
        _delegate = delegate;
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerHandler:(NSString*)handlerName responseHandler:(DCBridgeResponseHandler)handler{
    _messageHandlers[handlerName] = [handler copy];
}
- (void)removeHandler:(NSString*)handlerName{
    _messageHandlers[handlerName] = nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",message.body);
    
    if([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]){
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
    
    if ([message.name isEqualToString:@"DCJSBridge"]) {
        if ([message.body isKindOfClass:[NSDictionary class]]) {
            NSDictionary *param = message.body;
            //业务功能名称
            NSString *functionName = [param objectForKey:@"functionName"];
            //回调方法ID
            int callbackId = [[param objectForKey:@"callbackId"] intValue];
            //参数
            NSDictionary *args = [param objectForKey:@"message"];
            if(_messageHandlers[functionName]){
                DCBridgeResponseHandler handler = _messageHandlers[functionName];
                handler(callbackId, functionName,args);
            }
            [self handlerCallBack:functionName callbackId:callbackId args:args webView:message.webView];
        }
    }
}

// 方法回调
- (void)handlerCallBack:(NSString *)functionName callbackId:(int)callbackId args:(NSDictionary *)args webView:(id)webView{
    
    // 注册一个JS的回调
    //[self.bridgeHandler registerHandler:@"getIdentity" responseHandler:^(NSInteger callbackId, NSString * _Nonnull handlerName, id  _Nonnull responseData) {
    
    //}];
    
}

- (void)dealloc
{
    NSLog(@"dealloc DCJSCallHandle");
}

@end
