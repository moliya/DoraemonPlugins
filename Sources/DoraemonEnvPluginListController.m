//
//  DoraemonEnvPluginListController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import "DoraemonEnvPluginListController.h"
#import "DoraemonEnvPluginDetailController.h"

@interface DoraemonEnvPluginListController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation DoraemonEnvPluginListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"配置列表";
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCustomItem)];
    self.items = [NSMutableArray array];
    [self loadEnvData];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 54;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadEnvData];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [self.items[indexPath.row] objectForKey:@"key"];
    cell.detailTextLabel.text = [self.items[indexPath.row] objectForKey:@"value"];
    cell.detailTextLabel.textColor = UIColor.grayColor;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DoraemonEnvPluginDetailController *detailVC = [[DoraemonEnvPluginDetailController alloc] init];
    detailVC.key = [self.items[indexPath.row] objectForKey:@"key"];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.items removeObjectAtIndex:indexPath.row];
        [NSUserDefaults.standardUserDefaults setObject:self.items forKey:@"DoraemonEnvPluginCustomItems"];
        [self loadEnvData];
        [self.tableView reloadData];
    }
}

#pragma mark - Private
- (void)addCustomItem {
    DoraemonEnvPluginDetailController *detailVC = [[DoraemonEnvPluginDetailController alloc] init];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)loadEnvData {
    [self.items removeAllObjects];
    //读取plist数据
    NSArray *customItems = [NSUserDefaults.standardUserDefaults arrayForKey:@"DoraemonEnvPluginCustomItems"];
    [self.items addObjectsFromArray:customItems];
}

@end
