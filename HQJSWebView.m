//
//  HQJSWebView.m
//  HQWebViewWithJS
//
//  Created by 胡奇 on 2018/4/17.
//  Copyright © 2018年 胡奇. All rights reserved.
//

#define SuppressPerformSelectorLeakWarning(Stuff)\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop")
#define MethodFullName @"MethodFullName"
#define MethodTarget @"MethodTarget"

#import "HQJSWebView.h"


@interface HQJSWebView()

@property (nonatomic, strong) NSMutableDictionary *JS2OCHandleDict;
@property (nonatomic, strong) NSMutableArray<NSString *> *OC2JSHandleArray;

@end


@implementation HQJSWebView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame configuration:[[self class] defaultWebViewConfig]]) {
        self.UIDelegate = self;
        self.navigationDelegate = self;
        self.JS2OCHandleDict = [NSMutableDictionary dictionaryWithCapacity:0];
        self.OC2JSHandleArray = [NSMutableArray arrayWithCapacity:0];
        self.useNativeAlertController = YES;
    }
    return self;
}



- (void)registerOC2JSMethod:(NSString *)jsCode {
    if (self.OC2JSHandleArray) {
        [self.OC2JSHandleArray addObject:jsCode];
    } else {
        [self executeOC2JSMethod:jsCode];
    }
}

- (void)executeOC2JSMethod:(NSString *)jsCode {
    
    [self evaluateJavaScript:jsCode completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error");
        }
    }];
}


- (void)registerJS2OCMethod:(NSObject *)target handel:(SEL)selector {
    NSString *methodName = NSStringFromSelector(selector);
    [self.configuration.userContentController addScriptMessageHandler:self name:[methodName componentsSeparatedByString:@":"].firstObject];
    
    __weak NSObject *weakTarget = target;
    [self.JS2OCHandleDict setObject:@{MethodFullName:methodName, MethodTarget: weakTarget} forKey:[methodName componentsSeparatedByString:@":"].firstObject];
}

- (void)deleteJS2OCMethod:(SEL)selector {

    NSString *methodName = NSStringFromSelector(selector);
    [self.configuration.userContentController removeScriptMessageHandlerForName:methodName];
    [self.JS2OCHandleDict removeObjectForKey:methodName];
}

- (void)deleteAllJS2OCMethod {

    for (NSString *registerMethodName in self.JS2OCHandleDict) {
        [self.configuration.userContentController removeScriptMessageHandlerForName:registerMethodName];
    }
    
    [self.JS2OCHandleDict removeAllObjects];
}

- (nullable WKNavigation *)goBack {
    if ([super canGoBack]) {
        return [super goBack];
    } else {
        return nil;
    }
}

- (nullable WKNavigation *)goForward {
    if ([super canGoForward]) {
        return [super goForward];
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark JS调用OC关键方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {

    NSString *methodName = message.name;
    NSString *methodFullName = [[self.JS2OCHandleDict objectForKey:methodName] objectForKey:MethodFullName];
    NSObject *methodTarget = [[self.JS2OCHandleDict objectForKey:methodName] objectForKey:MethodTarget];
    
    if ([methodTarget respondsToSelector:NSSelectorFromString(methodFullName)]) {
        if ([methodFullName isEqualToString:methodName]) {
            SuppressPerformSelectorLeakWarning(
                [methodTarget performSelector:NSSelectorFromString(methodFullName)];
            )
        } else {
            SuppressPerformSelectorLeakWarning(
                [methodTarget performSelector:NSSelectorFromString(methodFullName) withObject:message.body];
            )
        }
    };

}

#pragma mark -

//  初始化
+ (WKWebViewConfiguration *)defaultWebViewConfig {
    
    WKWebViewConfiguration *webViewConfig = [[WKWebViewConfiguration alloc] init];
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    webViewConfig.userContentController = userController;

    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    webViewConfig.preferences = preferences;
    
    return webViewConfig;
}

#pragma mark -
#pragma mark WKUIDelegate

// 创建新的webView时调用的方法
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    [self loadRequest:navigationAction.request];
    
    return nil;
}


#pragma mark -
#pragma mark WKNavigationDelegate

//  页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(HQJSWebViewRequestDidStarted:)]) {
        [self.delegate HQJSWebViewRequestDidStarted:self];
    }
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    if (self.OC2JSHandleArray) {
        for (NSString * jsCode in self.OC2JSHandleArray) {
            [self executeOC2JSMethod:jsCode];
        }
        self.OC2JSHandleArray = nil;
    }
    
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(HQJSWebViewRequestDidFinished:)]) {
        [self.delegate HQJSWebViewRequestDidFinished:self];
    }
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    
    if (self.delegate && [(NSObject *)self.delegate respondsToSelector:@selector(HQJSWebViewRequestDidFailed:)]) {
        [self.delegate HQJSWebViewRequestDidFailed:self];
    }
}

- (void)deleteAllCookie {
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

// 在发送请求之前，决定是否跳转
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSMutableURLRequest *mutableRequest = [navigationAction.request mutableCopy];
//    NSDictionary *requestHeaders = navigationAction.request.allHTTPHeaderFields;
//
//    //cookie
//    [[NSUserDefaults standardUserDefaults] valueForKey:@""];
//
//    if (requestHeaders[@"token"]) {
//        decisionHandler(WKNavigationActionPolicyAllow);
//    } else {
//        [mutableRequest setValue:@"123456789" forHTTPHeaderField:@"token"];
//        [webView loadRequest:mutableRequest];
//        decisionHandler(WKNavigationActionPolicyCancel);
//
//    }
//}


//// 需要响应身份验证时调用 同样在block中需要传入用户身份凭证
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
//    //用户身份信息
//
//    NSLog(@"----需要响应身份验证时调用 同样在block中需要传入用户身份凭证");
//
//    NSURLCredential *newCred = [NSURLCredential credentialWithUser:@""
//                                                          password:@""
//                                                       persistence:NSURLCredentialPersistenceNone];
//    // 为 challenge 的发送方提供 credential
//    [[challenge sender] useCredential:newCred forAuthenticationChallenge:challenge];
//    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
//}

- (void)dealloc {
    NSLog(@"dealloc");
}

@end
