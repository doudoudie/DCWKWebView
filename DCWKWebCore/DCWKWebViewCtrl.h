//
//  DCWKWebViewCtrl.h
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCWKWebViewCtrl : UIViewController<WKNavigationDelegate>

@property (nonatomic,strong) NSURL *url;

@end

NS_ASSUME_NONNULL_END
