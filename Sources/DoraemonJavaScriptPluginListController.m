//
//  DoraemonJavaScriptPluginListController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/28.
//

#import "DoraemonJavaScriptPluginListController.h"
#import "DoraemonJavaScriptPluginDetailController.h"

@interface DoraemonJavaScriptPluginListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation DoraemonJavaScriptPluginListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"脚本列表";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewScript)];
    self.items = [NSMutableArray array];
    [self loadScriptData];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 100;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadScriptData];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [self.items[indexPath.row] objectForKey:@"value"];
    cell.textLabel.numberOfLines = 4;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DoraemonJavaScriptPluginDetailController *detailVC = [[DoraemonJavaScriptPluginDetailController alloc] init];
    detailVC.key = [self.items[indexPath.row] objectForKey:@"key"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeObjectAtIndex:indexPath.row];
        [NSUserDefaults.standardUserDefaults setObject:self.items forKey:@"DoraemonJavaScriptPluginScriptItems"];
        [self loadScriptData];
        [self.tableView reloadData];
    }
}

#pragma mark - Private
- (void)addNewScript {
    DoraemonJavaScriptPluginDetailController *detailVC = [[DoraemonJavaScriptPluginDetailController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)loadScriptData {
    [self.items removeAllObjects];
    //读取plist数据
    NSArray *scriptItems = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonJavaScriptPluginScriptItems"];
    if (!scriptItems) {
        //添加内置脚本
        NSMutableArray *tmp = [NSMutableArray array];
        [tmp addObject:@{
            @"key": @"Forward",
            @"value": @"//前进\nhistory.go(1)"
        }];
        [tmp addObject:@{
            @"key": @"Back",
            @"value": @"//后退\nhistory.go(-1)"
        }];
        [tmp addObject:@{
            @"key": @"Reload",
            @"value": @"//重新加载\nlocation.reload()"
        }];
        [tmp addObject:@{
            @"key": @"vConsole",
            @"value": @"//安装vConsole\nimport('https://unpkg.com/vconsole').then(() => {\n    new window.VConsole()\n})"
        }];
        [tmp addObject:@{
            @"key": @"Eruda",
            @"value": @"//安装Eruda\nimport('https://unpkg.com/eruda').then(() => {\n    eruda.init()\n})"
        }];
        scriptItems = tmp;
        [NSUserDefaults.standardUserDefaults setObject:scriptItems forKey:@"DoraemonJavaScriptPluginScriptItems"];
    }
    [self.items addObjectsFromArray:scriptItems];
}

@end
