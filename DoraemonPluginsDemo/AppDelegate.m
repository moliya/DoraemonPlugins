//
//  AppDelegate.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import "AppDelegate.h"
#import "Constant.h"

#ifdef DEBUG
#import <DoraemonKit/DoraemonKit.h>
#endif

#ifdef DEBUG
#import "DoraemonEnvPlugin.h"
#import "DoraemonJavaScriptPlugin.h"
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
    [DoraemonEnvPlugin installWithTitle:@"环境切换" icon:[UIImage imageNamed:@"icon_env"] desc:@"用于app内部环境切换" atModule:@"业务专区" handle:^(NSString * _Nonnull env, NSString * _Nonnull data) {
        // 解析Json
        NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:NULL];
        if (info) {
            appEnv = [info objectForKey:@"appEnv"];
            apiUrl = [info objectForKey:@"apiUrl"];
            cdnUrl = [info objectForKey:@"cdnUrl"];
            thirdSDKAppKey = [info objectForKey:@"thirdSDKAppKey"];
            [NSNotificationCenter.defaultCenter postNotificationName:@"AppEnvChangeNotification" object:nil];
        }
    }];
    [DoraemonEnvPlugin addDefaultEnv:@"正式环境" withData:@"{\"appEnv\":\"release\",\"apiUrl\":\"https://api.domain.com\",\"cdnUrl\":\"https://cdn.domain.com\",\"thirdSDKAppKey\":\"c56d0e9a7ccec67b4ea131655038d604\"}"];
    [DoraemonEnvPlugin addDefaultEnv:@"测试环境" withData:@"{\"appEnv\":\"debug\",\"apiUrl\":\"https://test-api.domain.com\",\"cdnUrl\":\"https://test-cdn.domain.com\",\"thirdSDKAppKey\":\"7a9e4b5025a8adc7d3208fd66806d685\"}"];
    
    [DoraemonJavaScriptPlugin installWithTitle:@"JS脚本" icon:[UIImage imageNamed:@"icon_js"] desc:@"用于在指定webView中执行JS代码" atModule:@"业务专区" handle:^(id  _Nullable result, NSError * _Nullable error) {
        NSLog(@"result: %@", result);
        NSLog(@"error: %@", error.localizedDescription);
    }];
    
    [DoraemonManager.shareInstance install];
#endif
    
    return YES;
}


@end
