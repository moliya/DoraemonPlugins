//
//  DoraemonJavaScriptPluginDetailController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/28.
//

#import "DoraemonJavaScriptPluginDetailController.h"
#import <DoraemonKit/DoraemonDefine.h>
#import <DoraemonKit/DoraemonToastUtil.h>
#import <DoraemonKit/DoraemonKit.h>
#import "DoraemonJavaScriptPlugin.h"

@interface DoraemonJavaScriptPluginDetailController ()

@property (nonatomic, weak) UITextView  *textView;

@end

@implementation DoraemonJavaScriptPluginDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"脚本执行";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(runScript)];
    UIEdgeInsets edge = UIEdgeInsetsMake(10, 10, 0, 10);
    CGFloat width = self.view.bounds.size.width - edge.left - edge.right;
    CGFloat height = self.view.bounds.size.height - edge.top - edge.bottom;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(edge.left, edge.top + IPHONE_NAVIGATIONBAR_HEIGHT, width, 30)];
    titleLabel.text = @"JS代码";
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(edge.left, CGRectGetMaxY(titleLabel.frame) + edge.top, width, height - 200)];
    textView.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
    textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    textView.layer.cornerRadius = 6;
    textView.font = [UIFont systemFontOfSize:16];
    textView.textContainerInset = UIEdgeInsetsMake(8, 3, 8, 3);
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:textView];
    self.textView = textView;
    
    if (self.key.length > 0) {
        NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonJavaScriptPluginScriptItems"];
        for (NSDictionary *dict in items) {
            NSString *key = [dict objectForKey:@"key"];
            NSString *value = [dict objectForKey:@"value"];
            if ([key isEqualToString:self.key]) {
                self.textView.text = value;
                break;
            }
        }
    }
}

#pragma mark - Private
- (void)runScript {
    NSString *key = self.key ?: [NSString stringWithFormat:@"%.0f", NSDate.date.timeIntervalSince1970];
    NSString *value = self.textView.text;
    if (value.length == 0) {
        [DoraemonToastUtil showToastBlack:@"脚本不能为空" inView:self.view];
        return;
    }
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonJavaScriptPluginScriptItems"];
    NSMutableArray *result = [NSMutableArray array];
    if (self.key.length == 0) {
        [result addObject:@{
            @"key": key,
            @"value": value
        }];
    }
    for (NSDictionary *dict in items) {
        //是否同名配置
        if ([[dict objectForKey:@"key"] isEqualToString:key]) {
            [result addObject:@{
                @"key": key,
                @"value": value
            }];
            continue;
        }
        [result addObject:dict];
    }
    //保存配置数据
    [NSUserDefaults.standardUserDefaults setObject:result forKey:@"DoraemonJavaScriptPluginScriptItems"];
    [DoraemonManager.shareInstance hiddenHomeWindow];
    [DoraemonJavaScriptPlugin evalJavaScript:value];
}

@end
