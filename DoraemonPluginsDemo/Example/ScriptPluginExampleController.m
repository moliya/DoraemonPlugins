//
//  ScriptPluginExampleController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/29.
//

#import "ScriptPluginExampleController.h"
#import <WebKit/WebKit.h>

@interface ScriptPluginExampleController ()

@property (weak, nonatomic) IBOutlet WKWebView *webView;

@end

@implementation ScriptPluginExampleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载网页
    NSURL *url = [NSURL URLWithString:@"https://www.infoq.cn/"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
