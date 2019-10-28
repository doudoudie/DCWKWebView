//
//  DCWKWebViewPool.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebViewPool.h"
#import "DCWKWebView.h"
#import "WKWebView+ExternalDelegate.h"
#import <objc/runtime.h>

@interface DCWKWebViewPool ()

@property (nonatomic, strong, readwrite) dispatch_semaphore_t lock;
@property (nonatomic, strong, readwrite) NSMutableDictionary *dequeueWKWebViews;// 当前在应用的队列
@property (nonatomic, strong, readwrite) NSMutableDictionary *enqueueWKWebViews;// 被复用的wkWebView放在此队列

@end

@implementation DCWKWebViewPool

+ (DCWKWebViewPool *)sharedInstance {
    static dispatch_once_t once;
    static DCWKWebViewPool *singlePool;
    dispatch_once(&once,
                  ^{
                      singlePool = [[DCWKWebViewPool alloc] init];
                  });
    return singlePool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dequeueWKWebViews = @{}.mutableCopy;
        _enqueueWKWebViews = @{}.mutableCopy;
        _lock = dispatch_semaphore_create(1);
        [self addObserverWithMemoryWarningClear];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dequeueWKWebViews removeAllObjects];
    [self.enqueueWKWebViews removeAllObjects];
    self.dequeueWKWebViews = nil;
    self.enqueueWKWebViews = nil;
}

#pragma mark - public method
- (DCWKWebView *)dequeueDCWKWebViewWithDelegate:(id)delegate configuration:(WKWebViewConfiguration *)configuration {
    
    if (!delegate) {
        return nil;
    }
    
    NSString *identifier = nil;
    if([delegate isKindOfClass:[NSString class]]){
        identifier = delegate;
    }else {
        identifier = [NSString stringWithUTF8String:object_getClassName(delegate)];
    }
    
    __kindof DCWKWebView *dequeueWebView = [self getWebViewWithIdentifier:identifier configuration:configuration];
    
    if(![delegate isKindOfClass:[NSString class]]){
        [dequeueWebView useExternalNavigationDelegate];
        dequeueWebView.mainNavigationDelegate = delegate;
    }
    return dequeueWebView;
}

- (void)enqueueDCWKWebView:(DCWKWebView *)wkWebView {
    
    if (!wkWebView) {
        NSLog(@"DCWKWebViewPool enqueue with invalid view:%@", wkWebView);
        return;
    }
    
    [wkWebView removeFromSuperview];
    
    [self recycleWKWebView:wkWebView];
}


#pragma mark - private method
- (DCWKWebView *)getWebViewWithIdentifier:(NSString *)identifier configuration:(WKWebViewConfiguration *)configuration{
    
    DCWKWebView *wkWebView = nil;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if([[_enqueueWKWebViews allKeys] containsObject:identifier]) {
        NSMutableSet *viewSet =  [_enqueueWKWebViews objectForKey:identifier];
        if (viewSet && viewSet.count > 0) {
            wkWebView = [viewSet anyObject];
            [viewSet removeObject:wkWebView];
        }
    }
    
    if (!wkWebView) {
        wkWebView = [[DCWKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        wkWebView.identifier = identifier;
    }else {
        wkWebView.configuration.userContentController = configuration.userContentController;
    }
    
    if ([[_dequeueWKWebViews allKeys] containsObject:identifier]) {
        NSMutableSet *viewSet =  [_dequeueWKWebViews objectForKey:identifier];
        [viewSet addObject:wkWebView];
    } else {
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:wkWebView];
        [_dequeueWKWebViews setValue:viewSet forKey:identifier];
    }
    
    [wkWebView clearBackForwardList];
    
    dispatch_semaphore_signal(_lock);
    
    return wkWebView;
}

- (void)recycleWKWebView:(DCWKWebView *)wkWebView {
    if (!wkWebView) {
        return;
    }
    
    //进入回收池前清理
    [wkWebView clearRequestEnterPool];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if ([[_dequeueWKWebViews allKeys] containsObject:wkWebView.identifier]) {
        NSMutableSet *viewSet =  [_dequeueWKWebViews objectForKey:wkWebView.identifier];
        [viewSet removeObject:wkWebView];
    } else {
        dispatch_semaphore_signal(_lock);
        NSLog(@"DCWKWebViewPool recycle invalid view");
    }
    
    if ([[_enqueueWKWebViews allKeys] containsObject:wkWebView.identifier]) {
        // 如果在g复用队列中存在
        NSMutableSet *viewSet =  [_enqueueWKWebViews objectForKey:wkWebView.identifier];
        [viewSet addObject:wkWebView];
        
    } else {
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:wkWebView];
        [_enqueueWKWebViews setValue:viewSet forKey:wkWebView.identifier];
    }
    
    
    dispatch_semaphore_signal(_lock);
}

- (void)addObserverWithMemoryWarningClear {
    //memory warning 时清理全部
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearAllReusableWebViews)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}

- (void)clearAllReusableWebViews {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [_enqueueWKWebViews removeAllObjects];
    dispatch_semaphore_signal(_lock);
}



@end
