//
//  DCWKWebViewConfig.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/23.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebViewConfig : NSObject

+ (instancetype)sharedInstance;

// 自定义协议列表
@property (nonatomic,strong) NSArray *protocols;

// 自定义的WKWebView UA, 方便自己程序识别
@property (nonatomic,strong) NSString *uaString;

// 主的域名
@property (nonatomic,strong) NSString *Domain;

// H5微信支付回调的Schemes | wxfq 是微信付钱的表示 避免wxpay关键字的出现
@property (nonatomic,strong) NSString *wxfqSchemes;

// 是否开启图片预览功能 
@property (nonatomic,assign) BOOL isOpenImagePreview;

// 防止长按图片的时候 不去触发点击预览的事件
@property (nonatomic,assign) BOOL longPressing;

@end

NS_ASSUME_NONNULL_END
