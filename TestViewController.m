//
//  TestViewController.m
//  HQWebViewWithJS
//
//  Created by 胡奇 on 2018/4/17.
//  Copyright © 2018年 胡奇. All rights reserved.
//

#import "TestViewController.h"
#import "HQJSWebView.h"

@interface TestViewController ()

@property (nonatomic, strong) HQJSWebView *webView;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.webView = [[HQJSWebView alloc] initWithFrame:self.view.bounds];
    
    
    
    [self.webView registerOC2JSMethod:@"OCCallJS1(1, 2, 3)"];
    [self.webView registerOC2JSMethod:@"OCCallJS2(10, 10, 10)"];
    [self.webView registerOC2JSMethod:@"OCCallJS3(5, 5, 5)"];

    [self.view addSubview:self.webView];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.252.187.22/"]]];
    [self.webView registerJS2OCMethod:self handel:@selector(testMethod:)];
    
//    [self performSelector:@selector(test:) withObject:webView afterDelay:5];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.webView) {
        [self.webView deleteAllJS2OCMethod];
    }
}

- (void)testMethod:(NSString *)test{
    NSLog(@"testMethod = %@", test);
}

- (void)test:(HQJSWebView *)webView {
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://10.252.187.22/"]]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
