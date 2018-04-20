//
//  HQJSWebView.h
//  HQWebViewWithJS
//
//  Created by 胡奇 on 2018/4/17.
//  Copyright © 2018年 胡奇. All rights reserved.
//



#import <WebKit/WebKit.h>

@protocol HQJSWebViewDelegate;

@interface HQJSWebView : WKWebView <WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, nullable, weak) id <HQJSWebViewDelegate> delegate;
@property (nonatomic, assign) BOOL useNativeAlertController;
//  初始化
- (instancetype)initWithFrame:(CGRect)frame;

//  注册OC2JS方法
- (void)registerOC2JSMethod:(NSString *)jsCode;

//  执行OC2JS方法
- (void)executeOC2JSMethod:(NSString *)jsCode;

//  注册JS2OC方法
- (void)registerJS2OCMethod:(NSObject *)target handel:(SEL)selector;

//  删除注册的JS2OC方法   否则不能释放webview
- (void)deleteJS2OCMethod:(SEL)selector;
- (void)deleteAllJS2OCMethod;

//  删除cookie
- (void)deleteAllCookie;


// webview前进后退
- (nullable WKNavigation *)goBack;
- (nullable WKNavigation *)goForward;

@end

@protocol HQJSWebViewDelegate <NSObject>

- (void)HQJSWebViewRequestDidStarted:(HQJSWebView *)webView;
- (void)HQJSWebViewRequestDidFinished:(HQJSWebView *)webView;
- (void)HQJSWebViewRequestDidFailed:(HQJSWebView *)webView;


@end
