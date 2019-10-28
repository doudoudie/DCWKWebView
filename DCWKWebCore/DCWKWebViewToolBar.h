//
//  DCWKWebViewTooBar.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/16.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCWKWebView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DCWKWebViewToolBarProtocol
/*
 
 */
- (void)goBack;

- (void)goForward;

@end

@interface DCWKWebViewToolBar : UIView

- (instancetype)initWithFrame:(CGRect)frame withWkWebView:(DCWKWebView *)wkWebView;

- (void)refreshButtonsSataus;

@end

NS_ASSUME_NONNULL_END
