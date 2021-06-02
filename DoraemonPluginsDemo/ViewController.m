//
//  ViewController.m
//  DoraemonPluginsDemo
//
//  Created by carefree on 2021/6/1.
//

#import "ViewController.h"
#import "Constant.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUrl) userInfo:nil repeats:YES];
}

- (void)updateUrl {
    self.textView.text = apiUrl;
}

@end
