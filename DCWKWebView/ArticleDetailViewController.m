//
//  ArticleDetailViewController.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/29.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "ArticleDetailViewController.h"
#import "DCWKWebView.h"
#import "DCWKWebMnager.h"

@interface ArticleDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) DCWKWebView *wkWebView;
@property (nonatomic,strong) UITableView *tableView;
@end

@implementation ArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"文章详细";
    
    [self.view addSubview:self.tableView];
    
    self.tableView.tableHeaderView = self.wkWebView;
    [self.tableView reloadData];
}

- (UITableView *)tableView {
    if(!_tableView){
        _tableView = [[UITableView alloc]  initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}

- (DCWKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[DCWKWebMnager sharedInstance] dequeueDCWKWebViewWithDelegate:self];
        _wkWebView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
        [_wkWebView requestUrl:[NSURL URLWithString:self.url]];
        
    }
    return _wkWebView;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = @"推荐或者评论区域";
    
    return cell;
}

#pragma mark - wkWebViewContentSize 高度的回调
- (void)wkWebViewContentSizeHeight:(CGFloat)height {
    _wkWebView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, height);
    self.tableView.tableHeaderView = self.wkWebView;
    //[self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
