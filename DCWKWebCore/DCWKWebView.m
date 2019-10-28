//
//  DCWKWebView.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebView.h"
#import "WKWebView+ExternalDelegate.h"
#import "DCWKWebViewHandle.h"

@interface DCWKWebView ()<UIGestureRecognizerDelegate>

@end

@implementation DCWKWebView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    self = [super initWithFrame:frame configuration:configuration];
    if(self){
        [self useExternalNavigationDelegate];
        [self addLongPress];
    }
    
    return self;
}

- (void)postUrl:(NSURL *)url {
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)clearRequestEnterPool {
    self.scrollView.delegate = nil;
    self.scrollView.scrollEnabled = YES;
    [self stopLoading];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
}

- (void)addLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.2;
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [sender locationInView:self];
    // 获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src",touchPoint.x, touchPoint.y];
    
    [[DCWKWebViewHandle new] downLoadImageWithJS:imgJS wkWebView:self];
}

#pragma mark - clear backForwardList

- (void)clearBackForwardList {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_re", @"moveA", @"llIte", @"ms"]);
    if ([self.backForwardList respondsToSelector:sel]) {
        [self.backForwardList performSelector:sel];
    }
#pragma clang diagnostic pop
}

- (void)dealloc
{
    NSLog(@"dealloc DCWKWebView");
}

@end
