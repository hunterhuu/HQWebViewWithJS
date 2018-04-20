//
//  ViewController.h
//  HQWebViewWithJS
//
//  Created by 胡奇 on 2018/4/11.
//  Copyright © 2018年 胡奇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController <WKUIDelegate, WKNavigationDelegate, UIWebViewDelegate, WKScriptMessageHandler>

@end

