//
//  DCWKWebViewConfig.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/23.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebViewConfig.h"

@implementation DCWKWebViewConfig

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DCWKWebViewConfig alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self){
        _longPressing = NO;
    }
    
    return self;
}

@end
