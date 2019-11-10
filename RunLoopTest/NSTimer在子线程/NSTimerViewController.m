//
//  NSTimerViewController.m
//  RunLoopTest
//
//  Created by JackMa on 2019/11/8.
//  Copyright © 2019 fire. All rights reserved.
//

#import "NSTimerViewController.h"

@interface NSTimerViewController ()

@property (nonatomic, strong) NSThread *thread;

@end

@implementation NSTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self timerAddSubThreadTest1];
    
    [self timerAddSubThreadTest2];
}

#pragma mark - NSTimer在子线程运行解决不准的问题

- (void)timerAddSubThreadTest1 {
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(displayCount) object:nil];
    [self.thread start];
}

- (void)displayCount {
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(log) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] run];
}

- (void)log {
    NSLog(@"hello world");
}

#pragma mark - NSTimer在子线程运行解决不准的问题（2）
#pragma mark - NSTimer常驻线程模拟耗时操作

- (void)timerAddSubThreadTest2 {
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"%@", [NSThread currentThread]);
        static int count = 0;
        [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"%s -- %d", __func__, count++);
        }];
        [[NSRunLoop currentRunLoop] run];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
