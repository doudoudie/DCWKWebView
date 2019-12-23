//
//  ViewController.m
//  DCWKWebView
//
//  Created by 登登 on 2019/9/27.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "ViewController.h"
#import "DCWKWebViewCtrl.h"
#import "TestDCWKWebView.h"
#import "ArticleDetailViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *demoTableView;
@property (nonatomic,copy) NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"测试demo";
    
    self.demoTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    NSDictionary *data1 = @{@"title":@"自定义JSBridge-统一代理回调",@"url":[[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"],@"intro":@"",@"type":@"2"};
    NSDictionary *data2 = @{@"title":@"JS注入测试",@"url":[[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"],@"intro":@"",@"type":@"2"};
    NSDictionary *data3 = @{@"title":@"内部协议测试",@"url":[[NSBundle mainBundle] URLForResource:@"article" withExtension:@"html"],@"intro":@"",@"type":@"1"};
    NSDictionary *data4 = @{@"title":@"长按识别二维码和保存图片",@"url":@"https://mp.weixin.qq.com/s/Cl_-X6olRxOfjgmiTPKigw",@"intro":@"",@"type":@"1"};
    NSDictionary *data5 = @{@"title":@"点击放到图片预览",@"url":@"https://mp.weixin.qq.com/s/Cl_-X6olRxOfjgmiTPKigw",@"intro":@"",@"type":@"1"};
    NSDictionary *data6 = @{@"title":@"支持底部ToolBar-前进和后退",@"url":@"https://www.jianshu.com/p/793a64ab17e5",@"intro":@"",@"type":@"1"};
    NSDictionary *data7 = @{@"title":@"H5微信支付和返回原生App",@"url":@"https://wxpay.wxutil.com/mch/pay/h5.v2.php",@"intro":@"",@"type":@"1"};
    NSDictionary *data13 = @{@"title":@"H5支付宝支付和返回原生App",@"url":@"https://m.pay.verystar.net/h5demo/",@"intro":@"",@"type":@"1"};
    NSDictionary *data8 = @{@"title":@"自定义MenuItems (未实现)",@"url":@"https://wxpay.wxutil.com/mch/pay/h5.v2.php",@"intro":@"",@"type":@"7"};
    NSDictionary *data9 = @{@"title":@"支持POST请求",@"url":[[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"],@"intro":@"",@"type":@"3"};
    NSDictionary *data10 = @{@"title":@"文章详情-测试回调高度",@"url":@"https://mp.weixin.qq.com/s/Q1AT6iHtJ83pcuflUEmeNg",@"type":@"4"};
    NSDictionary *data12 = @{@"title":@"用自带的WK控制器-注册回调JSBridge",@"url":[[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"],@"type":@"1"};
    NSDictionary *data11 = @{@"title":@"不使用自带WK的控制器-注册回调JSBridge",@"url":[[NSBundle mainBundle] URLForResource:@"simple" withExtension:@"html"],@"type":@"5"};
    NSDictionary *data14 = @{@"title":@"不使用自带的控制器-注册回调",@"url":@"",@"intro":@"",@"type":@"6"};
    self.dataArray = @[data1,data2,data3,data4,data5,data6,data7,data13,data8,data9,data10,data12,data11,data14];
    
    self.demoTableView.delegate = self;
    self.demoTableView.dataSource = self;
    self.demoTableView.tableFooterView = [UIView new];
    
    [self.view addSubview:self.demoTableView];
    //[self.demoTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"demoCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *dictionary = self.dataArray[indexPath.row];
    
    cell.textLabel.text = dictionary[@"title"];
    
    return cell;
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dictionary = self.dataArray[indexPath.row];
    if([dictionary[@"type"] integerValue] == 1){
        [self pushToWKWebView:dictionary[@"url"]];
    }else if([dictionary[@"type"] integerValue] == 2 || [dictionary[@"type"] integerValue] == 3 || [dictionary[@"type"] integerValue] == 5){
        TestDCWKWebView *ctrl = [[TestDCWKWebView alloc] init];
        ctrl.test_Url = dictionary[@"url"];
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if([dictionary[@"type"] integerValue] == 4){
        ArticleDetailViewController *ctrl = [[ArticleDetailViewController alloc] init];
        ctrl.url = dictionary[@"url"];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

- (void)pushToWKWebView:(id)url {
    DCWKWebViewCtrl *ctrl = [DCWKWebViewCtrl new];
    if([url isKindOfClass:[NSURL class]]){
       ctrl.url = url;
    }else {
        ctrl.url = [NSURL URLWithString:url];
    }
    [self.navigationController pushViewController:ctrl animated:YES];
}

@end
