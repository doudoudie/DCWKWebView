//
//  DCWKWebViewTooBar.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/16.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebViewToolBar.h"

@interface  DCWKWebViewToolBar()
@property (nonatomic,strong,readwrite) DCWKWebView *wkWebView;
@property (nonatomic,strong) UIButton *goBackButton;
@property (nonatomic,strong) UIButton *goForwardButton;
@end

@implementation DCWKWebViewToolBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame withWkWebView:(DCWKWebView *)wkWebView {
    self = [super initWithFrame:frame];
    if(self) {
        _wkWebView = wkWebView;
        self.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1];
        [self initToolBarUI];
    }
    return self;
}

- (void)initToolBarUI {
    CGFloat centerLine = [UIScreen mainScreen].bounds.size.width / 2;
    
    self.goBackButton = [[UIButton alloc] initWithFrame:CGRectMake(centerLine - 15 - 32, 13, 32, 32)];
    [self.goBackButton setImage:[UIImage imageNamed:@"arrow_left_dark"] forState:UIControlStateNormal];
    [self.goBackButton setImage:[UIImage imageNamed:@"arrow_left_light"] forState:UIControlStateSelected];
    [self.goBackButton addTarget:self action:@selector(goBackButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.goBackButton];
    
    self.goForwardButton = [[UIButton alloc] initWithFrame:CGRectMake(centerLine + 15, 13, 32, 32)];
    [self.goForwardButton setImage:[UIImage imageNamed:@"arrow_right_dark"] forState:UIControlStateNormal];
    [self.goForwardButton setImage:[UIImage imageNamed:@"arrow_right_light"] forState:UIControlStateSelected];
    [self.goForwardButton addTarget:self action:@selector(goForwardButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.goForwardButton];
    
}

- (void)goBackButtonAction:(id)sender {
    [self.wkWebView goBack];
    [self refreshButtonsSataus];
}

- (void)goForwardButtonAction:(id)sender {
    [self.wkWebView goForward];
    [self refreshButtonsSataus];
}

- (void)refreshButtonsSataus {
    
    if(self.hidden) return;
    
    if([self.wkWebView canGoBack]){
        self.goBackButton.selected = NO;
        self.goBackButton.enabled = YES;
    }else {
        self.goBackButton.selected = YES;
        self.goBackButton.enabled = NO;
    }
    
    if([self.wkWebView canGoForward]){
        self.goForwardButton.selected = NO;
        self.goForwardButton.enabled = YES;
    }else {
        self.goForwardButton.selected = YES;
        self.goForwardButton.enabled = NO;
    }
}

@end
