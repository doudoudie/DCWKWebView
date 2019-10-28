//
//  DCJSCallBack.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^DCBridgeResponseHandler)(NSInteger callbackId,NSString *handlerName, id responseData);

@interface DCJSBridgeHandler : NSObject<WKScriptMessageHandler>

-(instancetype)initWithDelegate:(id)delegate;

- (void)registerHandler:(NSString*)handlerName responseHandler:(DCBridgeResponseHandler)handler;

- (void)removeHandler:(NSString*)handlerName;

@end

NS_ASSUME_NONNULL_END
