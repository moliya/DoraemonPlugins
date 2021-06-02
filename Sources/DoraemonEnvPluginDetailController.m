//
//  DoraemonEnvPluginDetailController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import "DoraemonEnvPluginDetailController.h"
#import <DoraemonKit/DoraemonDefine.h>
#import <DoraemonKit/UIColor+Doraemon.h>
#import <DoraemonKit/DoraemonToastUtil.h>
#import "DoraemonEnvPlugin.h"

@interface DoraemonEnvPluginDetailController ()<UITextViewDelegate>

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) UITextView  *textView;

@end

@implementation DoraemonEnvPluginDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"配置详情";
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData)];
    UIEdgeInsets edge = UIEdgeInsetsMake(10, 10, 0, 10);
    CGFloat width = self.view.bounds.size.width - edge.left - edge.right;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(edge.left, edge.top + IPHONE_NAVIGATIONBAR_HEIGHT, width, 30)];
    titleLabel.text = @"名称";
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(edge.left, CGRectGetMaxY(titleLabel.frame) + edge.top, width, 50)];
    textField.placeholder = @"请输入配置名称";
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.layer.cornerRadius = 6;
    
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(edge.left, CGRectGetMaxY(textField.frame) + edge.top, width, 30)];
    valueLabel.text = @"配置数据";
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(edge.left, CGRectGetMaxY(valueLabel.frame) + edge.top, width, 200)];
    textView.layer.borderWidth = 1 / UIScreen.mainScreen.scale;
    textView.layer.borderColor = [UIColor doraemon_colorWithHexString:@"#d5d5d5"].CGColor;
    textView.layer.cornerRadius = 6;
    textView.font = [UIFont systemFontOfSize:16];
    textView.textContainerInset = UIEdgeInsetsMake(8, 3, 8, 3);
    textView.delegate = self;
    
    UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 5, width - 10, 24)];
    placeholderLabel.textColor = [UIColor doraemon_colorWithHexString:@"#c3c3c3"];
    placeholderLabel.text = @"请输入配置数据";
    placeholderLabel.hidden = self.key.length > 0;
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:textField];
    [self.view addSubview:valueLabel];
    [self.view addSubview:textView];
    [textView addSubview:placeholderLabel];
    self.textField = textField;
    self.textView = textView;
    
    if (self.key.length > 0) {
        NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonEnvPluginCustomItems"];
        for (NSDictionary *dict in items) {
            NSString *key = [dict objectForKey:@"key"];
            NSString *value = [dict objectForKey:@"value"];
            if ([key isEqualToString:self.key]) {
                self.textField.text = key;
                self.textView.text = value;
                break;
            }
        }
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    for (UIView *subview in textView.subviews) {
        if ([subview isKindOfClass:UILabel.class]) {
            subview.hidden = textView.text.length > 0;
        }
    }
}

#pragma mark - Private
- (void)saveData {
    NSString *title = self.textField.text;
    NSString *value = self.textView.text;
    if (title.length == 0) {
        [DoraemonToastUtil showToastBlack:@"名称不能为空" inView:self.view];
        return;
    }
    if (value.length == 0) {
        [DoraemonToastUtil showToastBlack:@"配置不能为空" inView:self.view];
        return;
    }
    NSArray *items = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonEnvPluginCustomItems"];
    NSMutableArray *result = [NSMutableArray array];
    BOOL shouldSave = YES;
    BOOL isAdd = self.key.length == 0;
    if (isAdd) {
        [result addObject:@{
            @"key": title,
            @"value": value
        }];
    }
    for (NSDictionary *dict in items) {
        if (isAdd) {
            //是否存在同名配置
            if ([[dict objectForKey:@"key"] isEqualToString:title]) {
                shouldSave = NO;
                [DoraemonToastUtil showToastBlack:@"无法保存，存在同名的配置" inView:self.view];
                break;
            }
        } else {
            if ([[dict objectForKey:@"key"] isEqualToString:title]) {
                [result addObject:@{
                    @"key": title,
                    @"value": value
                }];
                continue;
            }
        }
        [result addObject:dict];
    }
    if (!shouldSave) {
        return;
    }
    //保存配置数据
    [NSUserDefaults.standardUserDefaults setObject:result forKey:@"DoraemonEnvPluginCustomItems"];
    //如果更新的是正在使用的配置，则执行回调方法
    NSString *current = [NSUserDefaults.standardUserDefaults stringForKey:@"DoraemonEnvPluginCurrentKey"];
    if ([current isEqualToString:title]) {
        [DoraemonEnvPlugin manualUpdateEnv:title withData:value];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
