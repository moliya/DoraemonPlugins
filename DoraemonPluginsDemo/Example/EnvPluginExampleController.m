//
//  EnvPluginExampleController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2022/4/29.
//

#import "EnvPluginExampleController.h"
#import "Constant.h"

@interface EnvPluginExampleController ()

@property (weak, nonatomic) IBOutlet UILabel *envLabel;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *cdnLabel;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;

@end

@implementation EnvPluginExampleController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.envLabel.text = [NSString stringWithFormat:@"当前环境：%@", appEnv];
    self.urlLabel.text = [NSString stringWithFormat:@"接口地址：%@", apiUrl];
    self.cdnLabel.text = [NSString stringWithFormat:@"cdn地址：%@", cdnUrl];
    self.keyLabel.text = [NSString stringWithFormat:@"其他Key：%@", thirdSDKAppKey];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateEnv) name:@"AppEnvChangeNotification" object:nil];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)updateEnv {
    self.envLabel.text = [NSString stringWithFormat:@"当前环境：%@", appEnv];
    self.urlLabel.text = [NSString stringWithFormat:@"接口地址：%@", apiUrl];
    self.cdnLabel.text = [NSString stringWithFormat:@"cdn地址：%@", cdnUrl];
    self.keyLabel.text = [NSString stringWithFormat:@"其他Key：%@", thirdSDKAppKey];
}

@end
