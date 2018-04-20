//
//  ViewController.m
//  HQWebViewWithJS
//
//  Created by 胡奇 on 2018/4/11.
//  Copyright © 2018年 胡奇. All rights reserved.
//

/*
    OC              JS
 nil                undefined
 NSNull             null
 NSString           string
 NSNumber           number,boolean
 NSDictionary       Object object
 NSArray            Array object
 NSDate             Date object
 NSBlock(1)         Function object(1)
 id(2)              Wrapper object(2)
 Class(3)           Constructor object(3)
 
 */

#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface ViewController ()

@property (nonatomic, strong) WKWebView *webview;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    
    //注册
    [userController addScriptMessageHandler:self name:@"iOSMethodName"];
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    webViewConfig.preferences = preferences;
    
    
    
    webViewConfig.userContentController = userController;

    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webViewConfig];
    self.webview.UIDelegate = self;
    self.webview.navigationDelegate = self;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.252.187.22/"]]];

    [self.view addSubview:self.webview];
    
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithTitle:@"testMethod" style:UIBarButtonItemStylePlain target:self action:@selector(testMethod)];
    self.navigationItem.leftBarButtonItem = barBtn;
    
}

- (void)testMethod {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0)
    {
        
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             for (WKWebsiteDataRecord *record  in records)
                             {
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                           forDataRecords:@[record]
                                                                        completionHandler:^{
                                                                            NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                        }];
                             }
                         }];
        
    }
    
    
    
}

- (void)goBack {
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

#pragma mark -
#pragma mark OC调用JS

- (void)JSMethodJump {
    
//    NSString *jsStr = [NSString stringWithFormat:@"ocCallJS('%@')", @{@"key":@"value"}];
    NSString *jsStr = @"OCCallJS('1st', '2nd', '3rd')";

    [self.webview evaluateJavaScript:jsStr completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"data = %@", data);
        if (error) {
            NSLog(@"error");
        }
    }];

}

#pragma mark -
#pragma mark JS调用OC

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    // 判断是否是调用原生的
    NSLog(@"message.name = %@", message.name);
    NSLog(@"message.body = %@", message.body);
    
    NSDictionary *tempDict = (NSDictionary *)message.body;
    
    NSLog(@"tempDict.content = %@", tempDict[@"content"]);

}

#pragma mark -
#pragma mark WKUIDelegate

// 创建新的webView时调用的方法
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    NSLog(@"-----创建新的webView时调用的方法");
    [self.webview loadRequest:navigationAction.request];

    
    return nil;
}

// 关闭webView时调用的方法
- (void)webViewDidClose:(WKWebView *)webView {
    
    NSLog(@"----关闭webView时调用的方法");
}





// 允许应用程序向它创建的视图控制器弹出
- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    
    NSLog(@"----允许应用程序向它创建的视图控制器弹出");
    
}

// 显示一个文件上传面板。completionhandler完成处理程序调用后打开面板已被撤销。通过选择的网址，如果用户选择确定，否则为零。如果不实现此方法，Web视图将表现为如果用户选择了取消按钮。
- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable URLs))completionHandler {
    
    NSLog(@"----显示一个文件上传面板");
    
}

#pragma mark -
#pragma mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
    
    if (requestHeaders[@"token"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        [mutableRequest setValue:@"123456789" forHTTPHeaderField:@"token"];
        [webView loadRequest:mutableRequest];
        decisionHandler(WKNavigationActionPolicyCancel);
        
    }
}

// 2 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"2-------页面开始加载时调用");
}

// 3 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    /// 在收到服务器的响应头，根据response相关信息，决定是否跳转。decisionHandler必须调用，来决定是否跳转，参数WKNavigationActionPolicyCancel取消跳转，WKNavigationActionPolicyAllow允许跳转
    
    NSLog(@"3-------在收到响应后，决定是否跳转");
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 4 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"4-------当内容开始返回时调用");
}

// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"5-------页面加载完成之后调用");
}

// 6 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"6-------页面加载失败时调用");
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"-------接收到服务器跳转请求之后调用");
}

// 数据加载发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"----数据加载发生错误时调用");
}

// 需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    //用户身份信息
    
    NSLog(@"----需要响应身份验证时调用 同样在block中需要传入用户身份凭证");
    
    NSURLCredential *newCred = [NSURLCredential credentialWithUser:@""
                                                          password:@""
                                                       persistence:NSURLCredentialPersistenceNone];
    // 为 challenge 的发送方提供 credential
    [[challenge sender] useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}

// 进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"----------进程被终止时调用");
}

#pragma mark -
#pragma mark JS

//  alert
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
        NSLog(@"alert");
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}


//  Confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

//  textinput
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {

    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields.firstObject.text);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark -

@end
