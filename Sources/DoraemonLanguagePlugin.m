//
//  DoraemonLanguagePlugin.m
//  DoraemonPlugins
//
//  Created by carefree on 2023/6/27.
//

#import "DoraemonLanguagePlugin.h"
#import <DoraemonKit/DoraemonKit.h>
#import <DoraemonKit/UIViewController+Doraemon.h>
#import <DoraemonKit/UIViewController+DoraemonHierarchy.h>
#import <DoraemonKit/DoraemonDefine.h>
#import <DoraemonKit/DoraemonHomeWindow.h>

@interface DoraemonLanguagePlugin ()

@property (nonatomic, strong) NSMutableArray    *defaultItems;
@property (nonatomic, copy, nullable) void (^handler)(NSString *title, NSString *code);
@property (nonatomic, assign) BOOL              matched;

@end

@implementation DoraemonLanguagePlugin

#pragma mark - Public
+ (void)installWithTitle:(NSString *)title icon:(id)imageOrString desc:(NSString *)desc atModule:(NSString *)moduleName handle:(void (^)(NSString * _Nonnull, NSString * _Nonnull))handleBlock {
    if ([imageOrString isKindOfClass:UIImage.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title image:(UIImage *)imageOrString desc:desc pluginName:@"DoraemonLanguagePlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    } else if ([imageOrString isKindOfClass:NSString.class]) {
        [DoraemonManager.shareInstance addPluginWithTitle:title icon:(NSString *)imageOrString desc:desc pluginName:@"DoraemonLanguagePlugin" atModule:moduleName handle:^(NSDictionary * _Nonnull itemData) {
            [self privateHandle:itemData];
        }];
    }
    DoraemonLanguagePlugin.shared.handler = handleBlock;
    [DoraemonLanguagePlugin.shared matchLanguageIfNeed];
}

+ (void)addDefaultLanguage:(NSString *)title withCode:(NSString *)languageCode {
    [DoraemonLanguagePlugin.shared.defaultItems addObject:@{
        @"key": title,
        @"value": languageCode
    }];
    [DoraemonLanguagePlugin.shared matchLanguageIfNeed];
}

#pragma mark - Private
+ (DoraemonLanguagePlugin *)shared {
    static dispatch_once_t onceToken;
    static DoraemonLanguagePlugin *plugin;
    dispatch_once(&onceToken, ^{
        plugin = [[DoraemonLanguagePlugin alloc] init];
        plugin.defaultItems = [NSMutableArray array];
    });
    return plugin;
}

+ (void)privateHandle:(NSDictionary *)data {
    [DoraemonManager.shareInstance hiddenHomeWindow];
    
    NSMutableArray *keyValues = [NSMutableArray array];
    //默认项
    [keyValues addObjectsFromArray:DoraemonLanguagePlugin.shared.defaultItems];
    
    NSString *title = [data objectForKey:@"name"];
    NSMutableArray *actions = [NSMutableArray array];
    NSString *currentAction = [NSUserDefaults.standardUserDefaults stringForKey:@"DoraemonLanguagePluginCurrentKey"];
    for (NSDictionary *dict in keyValues) {
        NSString *name = [dict objectForKey:@"key"];
        [actions addObject:name];
    }
    if (keyValues.count > 1) {
        //未找到匹配的选项
        if (!currentAction || !DoraemonLanguagePlugin.shared.matched) {
            //使用第一个选项
            currentAction = [keyValues.firstObject objectForKey:@"key"];
            [NSUserDefaults.standardUserDefaults setObject:currentAction forKey:@"DoraemonLanguagePluginCurrentKey"];
            DoraemonLanguagePlugin.shared.matched = YES;
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
            //保存选项
            [NSUserDefaults.standardUserDefaults setObject:key forKey:@"DoraemonLanguagePluginCurrentKey"];
            //回调
            if (DoraemonLanguagePlugin.shared.handler) {
                DoraemonLanguagePlugin.shared.handler(key, value);
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

- (void)matchLanguageIfNeed {
    if (self.matched) {
        return;
    }
    NSString *current = [NSUserDefaults.standardUserDefaults stringForKey:@"DoraemonLanguagePluginCurrentKey"];
    NSMutableArray *keyValues = [NSMutableArray array];
    //默认项
    [keyValues addObjectsFromArray:DoraemonLanguagePlugin.shared.defaultItems];
    
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
