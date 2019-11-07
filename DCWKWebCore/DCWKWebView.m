//
//  DCWKWebView.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebView.h"
#import "WKWebView+ExternalDelegate.h"
#import "WKWebView+DCExtension.h"
#import "DCWKWebViewHandle.h"
#import "DCWKWebViewMacro.h"

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

// 发起DCWKWebView的Request请求
- (void)requestUrl:(NSURL *)url {
    [self loadRequest:[NSURLRequest requestWithURL:url]];
}

// 发起DCWKWebView的Request请求 并且是POST的请求方式, 参数body里带
- (void)requestUrl:(NSURL *)url parameters:(NSDictionary *)params{
    
    if(params) {
    
        [self safeAsyncEvaluateJavaScriptString:DCPOST_JS];
        
        NSError *parseError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&parseError];
        
        NSString * dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // 要访问的地址
        NSString * url_string = [NSString stringWithFormat:@"%@",url];
        
        NSString * js = [NSString stringWithFormat:@"DC_POSTMethod(\"%@\", %@)",url_string,dataStr];
        // 最后执行JS代码
        [self safeAsyncEvaluateJavaScriptString:js];
    
    }else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        [self loadRequest:request];
    }
}

// 加载一段html代码的字符串
- (void)loadHtml:(NSString *)html {
    [self loadHTMLString:html baseURL:nil];
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
    longPress.minimumPressDuration = 0.5;
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
