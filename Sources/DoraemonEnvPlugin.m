//
//  DoraemonEnvPlugin.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import "DoraemonEnvPlugin.h"
#import <DoraemonKit/DoraemonKit.h>
#import <DoraemonKit/UIViewController+Doraemon.h>
#import <DoraemonKit/UIViewController+DoraemonHierarchy.h>
#import <DoraemonKit/DoraemonDefine.h>
#import <DoraemonKit/DoraemonHomeWindow.h>
#import "DoraemonEnvPluginListController.h"

@interface DoraemonEnvPlugin ()

@property (nonatomic, strong) NSMutableArray    *defaultItems;
@property (nonatomic, copy, nullable) void (^handler)(NSString *env, NSString *data);
@property (nonatomic, assign) BOOL              matched;

@end

@implementation DoraemonEnvPlugin

#pragma mark - Public
+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void (^)(NSString * _Nonnull, NSString * _Nonnull))handleBlock {
    if ([imageOrString isKindOfClass:UIImage.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title image:(UIImage *)imageOrString desc:desc pluginName:@"DoraemonEnvPlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    } else if ([imageOrString isKindOfClass:NSString.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title icon:(NSString *)imageOrString desc:desc pluginName:@"DoraemonEnvPlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    }
    DoraemonEnvPlugin.shared.handler = handleBlock;
    [DoraemonEnvPlugin.shared matchEnvIfNeed];
}

+ (void)addDefaultEnv:(NSString *)env withData:(NSString *)data {
    [DoraemonEnvPlugin.shared.defaultItems addObject:@{
        @"key": env,
        @"value": data
    }];
    [DoraemonEnvPlugin.shared matchEnvIfNeed];
}

+ (void)manualUpdateEnv:(NSString *)env withData:(NSString *)data {
    if (DoraemonEnvPlugin.shared.handler) {
        DoraemonEnvPlugin.shared.handler(env, data);
    }
}

#pragma mark - Private
+ (DoraemonEnvPlugin *)shared {
    static dispatch_once_t onceToken;
    static DoraemonEnvPlugin *plugin;
    dispatch_once(&onceToken, ^{
        plugin = [[DoraemonEnvPlugin alloc] init];
        plugin.defaultItems = [NSMutableArray array];
    });
    return plugin;
}

+ (void)privateHandle:(NSDictionary *)data {
    [DoraemonManager.shareInstance hiddenHomeWindow];
    
    NSMutableArray *keyValues = [NSMutableArray array];
    //默认项
    [keyValues addObjectsFromArray:DoraemonEnvPlugin.shared.defaultItems];
    //自定义项
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonEnvPluginCustomItems"];
    if (items) {
        [keyValues addObjectsFromArray:items];
    }
    //配置项
    [keyValues addObject:@{
        @"key": @"查看配置",
        @"value": @"ENV_CONFIG"
    }];
    
    NSString *title = [data objectForKey:@"name"];
    NSMutableArray *actions = [NSMutableArray array];
    NSString *currentAction = [NSUserDefaults.standardUserDefaults stringForKey:@"DoraemonEnvPluginCurrentKey"];
    for (NSDictionary *dict in keyValues) {
        NSString *name = [dict objectForKey:@"key"];
        [actions addObject:name];
    }
    if (keyValues.count > 1) {
        //未找到匹配的选项
        if (!currentAction || !DoraemonEnvPlugin.shared.matched) {
            //使用第一个选项
            currentAction = [keyValues.firstObject objectForKey:@"key"];
            [NSUserDefaults.standardUserDefaults setObject:currentAction forKey:@"DoraemonEnvPluginCurrentKey"];
            DoraemonEnvPlugin.shared.matched = YES;
        }
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < actions.count; i++) {
        NSString *actionTitle = actions[i];
        __block NSInteger index = i;
        UIAlertActionStyle style = i == actions.count - 1 ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault;
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionTitle style:style handler:^(UIAlertAction * _Nonnull action) {
            NSDictionary *dict = [keyValues objectAtIndex:index];
            NSString *key = [dict objectForKey:@"key"];
            NSString *value = [dict objectForKey:@"value"];
            if (index == actions.count - 1) {
                //打开配置页
                [DoraemonHomeWindow openPlugin:DoraemonEnvPluginListController.new];
                return;
            }
            //保存选项
            [NSUserDefaults.standardUserDefaults setObject:key forKey:@"DoraemonEnvPluginCurrentKey"];
            //回调
            if (DoraemonEnvPlugin.shared.handler) {
                DoraemonEnvPlugin.shared.handler(key, value);
            }
        }];
        if (currentAction && [actionTitle isEqualToString:currentAction]) {
            action.enabled = NO;
            [action setValue:[UIImage doraemon_xcassetImageNamed:@"doraemon_hierarchy_select"] forKey:@"image"];
        }
        [alert addAction:action];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIViewController.topViewControllerForKeyWindow presentViewController:alert animated:YES completion:nil];
    });
}

- (void)matchEnvIfNeed {
    if (self.matched) {
        return;
    }
    NSString *current = [NSUserDefaults.standardUserDefaults stringForKey:@"DoraemonEnvPluginCurrentKey"];
    NSMutableArray *keyValues = [NSMutableArray array];
    //默认项
    [keyValues addObjectsFromArray:DoraemonEnvPlugin.shared.defaultItems];
    //自定义项
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonEnvPluginCustomItems"];
    if (items) {
        [keyValues addObjectsFromArray:items];
    }
    for (NSDictionary *dict in keyValues) {
        NSString *key = [dict objectForKey:@"key"];
        if ([key isEqualToString:current]) {
            if (self.handler) {
                self.handler(key, [dict objectForKey:@"value"]);
            }
            self.matched = YES;
            break;
        }
    }
}

@end
