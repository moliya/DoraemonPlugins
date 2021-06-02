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
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
    [DoraemonEnvPlugin installWithTitle:@"环境切换" icon:[UIImage imageNamed:@"icon_env"] desc:@"用于app内部环境切换" atModule:@"业务专区" handle:^(NSString * _Nonnull env, NSString * _Nonnull data) {
        //接口地址
        apiUrl = data;
        //其他配置
        if ([env isEqualToString:@"正式环境"]) {
            cdnUrl = @"https://cdn.domain.com";
            thirdSDKAppKey = @"c56d0e9a7ccec67b4ea131655038d604";
        } else {
            cdnUrl = @"https://test-cdn.domain.com";
            thirdSDKAppKey = @"7a9e4b5025a8adc7d3208fd66806d685";
        }
    }];
    [DoraemonEnvPlugin addDefaultEnv:@"正式环境" withData:@"https://api.domain.com"];
    [DoraemonEnvPlugin addDefaultEnv:@"测试环境" withData:@"https://test-api.domain.com"];
    [DoraemonManager.shareInstance install];
#endif
    
    return YES;
}


@end
