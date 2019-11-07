//
//  DCWKWebViewMacro.h
//  DCWKWebView
//
//  Created by 登登 on 2019/10/16.
//  Copyright © 2019 黄登登. All rights reserved.
//

#ifndef DCWKWebViewMacro_h
#define DCWKWebViewMacro_h

#define NaviBarHeight                       44.0f

#define StatusBarHeight  [UIApplication sharedApplication].statusBarFrame.size.height

#define IphoneXScreen ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436) , [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(828, 1792) , [[UIScreen mainScreen] currentMode].size) ||CGSizeEqualToSize(CGSizeMake(750, 1624) , [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2688) , [[UIScreen mainScreen] currentMode].size) : NO)

#define DCPOST_JS  @"function DC_POSTMethod(path, params) {\
var method = \"POST\";\
var form = document.createElement(\"form\");\
form.setAttribute(\"method\", method);\
form.setAttribute(\"action\", path);\
for(var key in params){\
if (params.hasOwnProperty(key)) {\
var hiddenFild = document.createElement(\"input\");\
hiddenFild.setAttribute(\"type\", \"hidden\");\
hiddenFild.setAttribute(\"name\", key);\
hiddenFild.setAttribute(\"value\", params[key]);\
}\
form.appendChild(hiddenFild);\
}\
document.body.appendChild(form);\
form.submit();\
}"

// iPhoneX 适配
#define SafeTopHeight    (NaviBarHeight + StatusBarHeight)
#define SafeBottomHeight (IphoneXScreen?34:0)

#endif /* DCWKWebViewMacro_h */
