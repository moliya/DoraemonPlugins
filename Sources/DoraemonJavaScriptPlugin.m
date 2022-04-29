//
//  DoraemonJavaScriptPlugin.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/25.
//

#import "DoraemonJavaScriptPlugin.h"
#import "DoraemonKit.h"
#import "UIViewController+Doraemon.h"
#import "UIViewController+DoraemonHierarchy.h"
#import "DoraemonDefine.h"
#import "DoraemonHomeWindow.h"
#import <WebKit/WebKit.h>
#import "DoraemonJavaScriptPluginListController.h"

@interface UIView (DoraemonJavaScript)
@end

@implementation UIView (DoraemonJavaScript)
//用于查找指定类的view
- (NSArray *)doraemon_findViewsForClass:(Class)clazz {
    NSMutableArray *result = [NSMutableArray array];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:clazz]) {
            [result addObject:subview];
        }
        [result addObjectsFromArray:[subview doraemon_findViewsForClass:clazz]];
    }
    return result;
}
@end

@interface DoraemonJavaScriptPlugin()

@property (nonatomic, weak) id                webView;
@property (nonatomic, copy, nullable) void (^handler)(id, NSError *);

@end

@implementation DoraemonJavaScriptPlugin

#pragma mark - Public
+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void (^)(id _Nullable, NSError * _Nullable))handleBlock {
    if ([imageOrString isKindOfClass:UIImage.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title image:(UIImage *)imageOrString desc:desc pluginName:@"DoraemonJavaScriptPlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    } else if ([imageOrString isKindOfClass:NSString.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title icon:(NSString *)imageOrString desc:desc pluginName:@"DoraemonJavaScriptPlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    }
    DoraemonJavaScriptPlugin.shared.handler = handleBlock;
}

+ (void)evalJavaScript:(NSString *)script {
    id currentWebView = DoraemonJavaScriptPlugin.shared.webView;
    if (!currentWebView) {
        return;
    }
    if ([currentWebView isKindOfClass:WKWebView.class]) {
        WKWebView *webView = currentWebView;
        [webView evaluateJavaScript:script completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            DoraemonJavaScriptPlugin.shared.handler(result, error);
        }];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([currentWebView isKindOfClass:UIWebView.class]) {
        UIWebView *webView = currentWebView;
        NSString *result = [webView stringByEvaluatingJavaScriptFromString:script];
        DoraemonJavaScriptPlugin.shared.handler(result, nil);
    }
#pragma clang diagnostic pop
}

#pragma mark - Private
+ (DoraemonJavaScriptPlugin *)shared {
    static dispatch_once_t onceToken;
    static DoraemonJavaScriptPlugin *plugin;
    dispatch_once(&onceToken, ^{
        plugin = [[DoraemonJavaScriptPlugin alloc] init];
    });
    return plugin;
}

+ (void)privateHandle:(NSDictionary *)data {
    [DoraemonManager.shareInstance hiddenHomeWindow];
    
    NSMutableArray *webViews = [NSMutableArray array];
    // 查找当前window中的所有webView
    [webViews addObjectsFromArray:[[DoraemonUtil getKeyWindow] doraemon_findViewsForClass:WKWebView.class]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [webViews addObjectsFromArray:[[DoraemonUtil getKeyWindow] doraemon_findViewsForClass:UIWebView.class]];
#pragma clang diagnostic pop
    
    NSString *title = @"请选择WebView";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < webViews.count; i++) {
        WKWebView *webView = webViews[i];
        NSString *actionTitle = webView.description;
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self selectWebView:webView];
        }];
        [alert addAction:action];
    }
    if (webViews.count == 0) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"无可用的WebView" style:UIAlertActionStyleDestructive handler:nil];
        action.enabled = NO;
        [alert addAction:action];
    }
    if (webViews.count == 1) {
        //只有一个，则跳过选择
        [self selectWebView:webViews.firstObject];
        return;
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIViewController.topViewControllerForKeyWindow presentViewController:alert animated:YES completion:nil];
    });
}

+ (void)selectWebView:(id)webView {
    //选中的webView
    DoraemonJavaScriptPlugin.shared.webView = webView;
    //打开脚本页
    [DoraemonHomeWindow openPlugin:DoraemonJavaScriptPluginListController.new];
}

@end
