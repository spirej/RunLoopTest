//
//  ModeSourceTimerViewController.m
//  RunLoopTest
//
//  Created by JackMa on 2019/11/8.
//  Copyright © 2019 fire. All rights reserved.
//

#import "ModeSourceTimerViewController.h"

@interface ModeSourceTimerViewController ()

@end

@implementation ModeSourceTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotNotification:) name:@"helloMyNotification" object:nil];
    
    [self cfModeDemo];
}

#pragma mark - 点击测试

- (IBAction)modeDemo:(id)sender {
    [self cfModeDemo];
}

- (IBAction)timerDemo:(id)sender {
    [self cfTimerDemo];
}

- (IBAction)observerDemo:(id)sender {
    [self cfObserverDemo];
}

- (IBAction)sourceDemo:(id)sender {
}

#pragma mark - mode演练

- (void)cfModeDemo {
    CFRunLoopRef lp = CFRunLoopGetCurrent();
    CFRunLoopMode mode = CFRunLoopCopyCurrentMode(lp);
    NSLog(@"mode == %@", mode);
    CFArrayRef modeArray = CFRunLoopCopyAllModes(lp);
    NSLog(@"modeArray == %@", modeArray);
}

#pragma mark - timer演练

- (void)cfTimerDemo {
    // 定义runloop timer上下文
    CFRunLoopTimerContext context = {
        0,
        ((__bridge void *)self),
        NULL,
        NULL,
        NULL
    };
    // 获取当前的runloop
    CFRunLoopRef rlp = CFRunLoopGetCurrent();
    /**
    参数一:用于分配对象的内存
    参数二:在什么是触发 (距离现在)
    参数三:每隔多少时间触发一次
    参数四:未来参数
    参数五:CFRunLoopObserver的优先级 当在Runloop同一运行阶段中有多个CFRunLoopObserver 正常情况下使用0
    参数六:回调,比如触发事件,我就会来到这里
    参数七:上下文记录信息
    */
    // 创建runloop timer
    CFRunLoopTimerRef timerRef = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 1, 0, 0, sp_RunLoopTimerCallBack, &context);
    // 添加到当前的runloop
    CFRunLoopAddTimer(rlp, timerRef, kCFRunLoopDefaultMode);
}

void sp_RunLoopTimerCallBack(CFRunLoopTimerRef timer, void *info){
    NSLog(@"%@---%@",timer,info);
}

#pragma mark - observe演练

- (void)cfObserverDemo {
    CFRunLoopObserverContext context = {
            0,
            ((__bridge void *)self),
            NULL,
            NULL,
            NULL
        };
    CFRunLoopRef rlp = CFRunLoopGetCurrent();
    /**
     参数一:用于分配对象的内存
     参数二:你关注的事件
          kCFRunLoopEntry=(1<<0),
          kCFRunLoopBeforeTimers=(1<<1),
          kCFRunLoopBeforeSources=(1<<2),
          kCFRunLoopBeforeWaiting=(1<<5),
          kCFRunLoopAfterWaiting=(1<<6),
          kCFRunLoopExit=(1<<7),
          kCFRunLoopAllActivities=0x0FFFFFFFU
     参数三:CFRunLoopObserver是否循环调用
     参数四:CFRunLoopObserver的优先级 当在Runloop同一运行阶段中有多个CFRunLoopObserver 正常情况下使用0
     参数五:回调,比如触发事件,我就会来到这里
     参数六:上下文记录信息
     */
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, sp_RunLoopObserverCallBack, &context);
    CFRunLoopAddObserver(rlp, observerRef, kCFRunLoopDefaultMode);
}

void sp_RunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    NSLog(@"%lu-%@",activity,info);
}

#pragma mark - 测试观察

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"helloMyNotification" object:@"cooci"];
}

- (void)gotNotification:(NSNotification *)noti{
    NSLog(@"gotNotification = %@",noti);
}

@end
