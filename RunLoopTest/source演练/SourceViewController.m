//
//  SourceViewController.m
//  RunLoopTest
//
//  Created by JackMa on 2019/11/8.
//  Copyright © 2019 fire. All rights reserved.
//

#import "SourceViewController.h"
#import <objc/message.h>

@interface SourceViewController ()<NSPortDelegate>
@property (nonatomic, strong) NSPort* subThreadPort;
@property (nonatomic, strong) NSPort* mainThreadPort;
@end

@implementation SourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPort];
}

- (IBAction)source0:(UIButton *)sender {
    [self source0Demo];
}

- (IBAction)source1:(UIButton *)sender {
    [self source1Demo];
}

#pragma mark - source0 演练

- (void)source0Demo {
    //初始runloopSource上下文(点进去看知道是结构体对象)
    CFRunLoopSourceContext context = {
        0,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        schedule,
        cancel,
        perform,
    };
    /**
    参数一:传递NULL或kCFAllocatorDefault以使用当前默认分配器。
    参数二:优先级索引，指示处理运行循环源的顺序。这里我传0为了的就是自主回调
    参数三:为运行循环源保存上下文信息的结构
    */
    CFRunLoopSourceRef source0 = CFRunLoopSourceCreate(CFAllocatorGetDefault(), 0, &context);
    CFRunLoopRef rlp = CFRunLoopGetCurrent();
    CFRunLoopAddSource(rlp, source0, kCFRunLoopDefaultMode);
    // 发送一个执行信号
    CFRunLoopSourceSignal(source0);
    // 唤醒 runloop 防止沉睡状态
    CFRunLoopWakeUp(rlp);
    // 取消，移除
//    CFRunLoopRemoveSource(rlp, source0, kCFRunLoopDefaultMode);
//    CFRelease(rlp);
}

void schedule(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    NSLog(@"准备代发");
}

void perform(void *info){
    NSLog(@"代发ing...");
}

void cancel(void *info, CFRunLoopRef rl, CFRunLoopMode mode){
    NSLog(@"取消了,终止了!!!!");
}

#pragma mark - source1: port演示

- (void)source1Demo {
    
    NSMutableArray* components = [NSMutableArray array];
    NSData* data = [@"hello" dataUsingEncoding:NSUTF8StringEncoding];
    [components addObject:data];
    // 子线程向主线程发送数据
    [self.subThreadPort sendBeforeDate:[NSDate date] components:components from:self.mainThreadPort reserved:0];
}

// 线程之间通讯
// 主线程 -- data
// 子线程 -- data1
// 更加低层 -- 内核
// mach
#pragma mark - NSPortDelegate
- (void)handlePortMessage:(id)message {
    NSLog(@"%@", [NSThread currentThread]); // 子线程 - 主线程

    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([message class], &count);
    for (int i = 0; i<count; i++) {
        
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivars[i])];
        NSLog(@"%@",name); // -- components
    }
    
    sleep(1);
    if (![[NSThread currentThread] isMainThread]) {

        NSMutableArray* components = [NSMutableArray array];
        NSData* data = [@"world" dataUsingEncoding:NSUTF8StringEncoding];
        [components addObject:data];

        // 主线程向子线程发送数据
        [self.mainThreadPort sendBeforeDate:[NSDate date] components:components from:self.subThreadPort reserved:0];
    }
}

- (void)setupPort{
    
    self.mainThreadPort = [NSPort port];
    self.mainThreadPort.delegate = self;
    // port - source1 -- runloop
    [[NSRunLoop currentRunLoop] addPort:self.mainThreadPort forMode:NSDefaultRunLoopMode];

    [self task];
}

- (void)task {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        self.subThreadPort = [NSPort port];
        self.subThreadPort.delegate = self;
        
        [[NSRunLoop currentRunLoop] addPort:self.subThreadPort forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }];
    
    [thread start];
}

@end
