//
//  DCWKWebViewHandle.m
//  DCWKWebView
//
//  Created by 登登 on 2019/10/22.
//  Copyright © 2019 黄登登. All rights reserved.
//

#import "DCWKWebViewHandle.h"
#import "WKWebView+DCExtension.h"
#import "WKWebView+ExternalDelegate.h"
#import "DCWKWebViewConfig.h"

@interface DCWKWebViewHandle ()<UIActionSheetDelegate>
@property (nonatomic,strong) NSString *qrCodeContent;
@end

@implementation DCWKWebViewHandle

#pragma mark - 下载JS中包含的图片
- (void)downLoadImageWithJS:(NSString *)imgJS wkWebView:(WKWebView *)wkWebView {
    
    [wkWebView safeAsyncEvaluateJavaScriptString:imgJS completionBlock:^(NSObject * _Nonnull result) {
        id imgUrl = result;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        UIImage *image = [UIImage imageWithData:data];
        if (!image) {
            NSLog(@"读取图片失败");
            return;
        }
        
        NSLog(@"读取图片成功");
        [DCWKWebViewConfig sharedInstance].longPressing = YES;
        
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel Action");
            [DCWKWebViewConfig sharedInstance].longPressing = NO;
        }];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Save Action");
            [DCWKWebViewConfig sharedInstance].longPressing = NO;
            [self loadImageFinished:image];
        }];
        UIAlertAction *identifyAction = [UIAlertAction actionWithTitle:@"识别图片二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Cancel Action");
            [DCWKWebViewConfig sharedInstance].longPressing = NO;
            if ([wkWebView.mainNavigationDelegate respondsToSelector:@selector(wkWebViewQrCodeReader:)]) {
                [wkWebView.mainNavigationDelegate wkWebViewQrCodeReader:self.qrCodeContent];
            }
            
            id<UIApplicationDelegate> delegate = (id)[UIApplication sharedApplication].delegate;
            if ([delegate respondsToSelector:@selector(wkWebViewQrCodeReader:)]) {
                [delegate performSelector:@selector(wkWebViewQrCodeReader:) withObject:self.qrCodeContent];
            }
        }];
        if([self isAvailableQRcodeIn:image]){
            [actionSheet addAction:saveAction];
            [actionSheet addAction:identifyAction];
            [actionSheet addAction:cancelAction];
        }else {
            [actionSheet addAction:saveAction];
            [actionSheet addAction:cancelAction];
        }
        
        [[self rootViewController] presentViewController:actionSheet animated:YES completion:nil];
    }];
}

#pragma mark - 点击放大图片查看
+ (void)registerImageClick:(WKWebView *)wkWebView {

    // 如果图片预览功能未被开启 则不需要给img标签添加click事件
    if(![DCWKWebViewConfig sharedInstance].isOpenImagePreview) return;
    
    static  NSString * const registerImageClick_js = @"function registerImageClick(){\
    var imgs=document.getElementsByTagName('img');\
    var length=imgs.length;\
    for(var i=0;i<length;i++){\
    img=imgs[i];\
    img.onclick=function(){\
    window.location.href='image-preview://'+this.src}\
    }\
    }";

    // 加载js代码
    [wkWebView safeAsyncEvaluateJavaScriptString:registerImageClick_js];
    
    // 加载registerImageClick 事件
    [wkWebView safeAsyncEvaluateJavaScriptString:@"registerImageClick()"];
    
}

#pragma mark - 判断图片是否包含二维码
- (BOOL)isAvailableQRcodeIn:(UIImage *)img{
    UIImage *image = [self imageByInsetEdge:UIEdgeInsetsMake(-20, -20, -20, -20) withColor:[UIColor lightGrayColor] withImage:img];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        self.qrCodeContent = [feature.messageString copy];
        NSLog(@"二维码信息:%@", self.qrCodeContent);
        return YES;
    } else {
        NSLog(@"无可识别的二维码");
        return NO;
    }
}

- (UIImage *)imageByInsetEdge:(UIEdgeInsets)insets withColor:(UIColor *)color withImage:(UIImage *)image
{
    
    CGSize size = image.size;
    size.width -= insets.left + insets.right;
    size.height -= insets.top + insets.bottom;
    
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    
    CGRect rect = CGRectMake(-insets.left, -insets.top, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (color) {
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CGPathAddRect(path, NULL, rect);
        CGContextAddPath(context, path);
        CGContextEOFillPath(context);
        CGPathRelease(path);
    }
    
    [image drawInRect:rect];
    UIImage *insetEdgedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return insetEdgedImage;
}

#pragma mark - 保存图片到相册
- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    if(error != nil){
        NSLog(@"Save Image OK");
    }
}

+ (BOOL)containsInternalProtocolWithUrl:(NSString *)urlString {
    BOOL contains = NO;
    for (NSString *protocolPath in [DCWKWebViewConfig sharedInstance].protocols) {
        if([urlString hasPrefix:protocolPath]){
            contains = YES;
            break;
        }
    }
    
    return contains;
}

#pragma mark - 获取当前的 rootViewController
- (UIViewController *)rootViewController {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)vc;
        vc = tabVC.selectedViewController;
    }
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)vc;
        vc = nc.visibleViewController;
    }
    return vc;
}

#pragma mark - 16进制字符串转换成Color
+ (UIColor *)stringTOColor:(NSString *)str{
    
    if (!str || [str isEqualToString:@""]) {
        return nil;
    }
    unsigned red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[str substringWithRange:range]] scanHexInt:&blue];
    UIColor *color= [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1];
    return color;
}

@end
