//
//  DelayLoadImageViewController.m
//  RunLoopTest
//
//  Created by JackMa on 2019/11/8.
//  Copyright © 2019 fire. All rights reserved.
//

#import "DelayLoadImageViewController.h"
#import "MyTableViewCell.h"

typedef void(^SaveFuncBlock)(void);

@interface DelayLoadImageViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myListView;
// 存放任务的数组
@property (nonatomic, strong) NSMutableArray *saveTaskMarr;
// 最大任务数（超过最大任务数的任务就停止执行）
@property (nonatomic, assign) NSInteger maxTaskNumber;
// 任务执行的代码块
@property (nonatomic, copy) SaveFuncBlock saveFuncBlock;

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation DelayLoadImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_myListView registerNib:[UINib nibWithNibName:NSStringFromClass([MyTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellID];
    
    // 最大任务数可根据当前屏幕显示要加载的图片数算出，这里随意设置的值
    self.maxTaskNumber = 18;
    
    [self addRunloopObserver];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 repeats:self block:^(NSTimer * _Nonnull timer) {
       // 此方法主要是利用计时器事件保持runloop处于循环中，不用做任何处理
    }];
}

#pragma mark - init

- (NSMutableArray *)saveTaskMarr {
    if (!_saveTaskMarr) {
        _saveTaskMarr = [NSMutableArray array];
    }
    return _saveTaskMarr;
}

// 添加任务进数组保存
- (void)addTasks:(SaveFuncBlock)taskBlock {
    [self.saveTaskMarr addObject:taskBlock];
    // 超过每次最多执行的任务数就移除当前数组
    if (self.saveTaskMarr.count > self.maxTaskNumber) {
        [self.saveTaskMarr removeObjectAtIndex:0];
    }
}

#pragma mark - observe

//添加一个监听者RunloopObserver
-(void)addRunloopObserver{
    //获取当前的RunLoop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    //定义一个centext
    CFRunLoopObserverContext context = {
        0,
        ( __bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL
    };
    //定义一个观察者
    static CFRunLoopObserverRef defaultModeObsever;
    //创建观察者
    defaultModeObsever = CFRunLoopObserverCreate(NULL,
                                                 kCFRunLoopBeforeWaiting,
                                                 YES,
                                                 0,
                                                 &Callback,
                                                 &context
                                                 );
    
    //添加当前RunLoop的观察者
    CFRunLoopAddObserver(runloop, defaultModeObsever, kCFRunLoopDefaultMode);
    //c语言有creat 就需要release
    CFRelease(defaultModeObsever);
}

//定义一个回调函数  一次RunLoop来一次
static void Callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    DelayLoadImageViewController * vcSelf = (__bridge DelayLoadImageViewController *)(info);
    
    if (vcSelf.saveTaskMarr.count > 0) {
        
        //获取一次数组里面的任务并执行
        SaveFuncBlock funcBlock = vcSelf.saveTaskMarr.firstObject;
        funcBlock();
        [vcSelf.saveTaskMarr removeObjectAtIndex:0];
    }
}

#pragma mark - UITableViewDelegate DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 300;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    // 添加任务到数组
    [self addTasks:^{
        // 下载图片的任务
        [cell.icon1 setImage:[UIImage imageNamed:@"1.jpg"]];
        [cell.icon2 setImage:[UIImage imageNamed:@"2.jpeg"]];
        [cell.icon3 setImage:[UIImage imageNamed:@"3.jpg"]];
    }];

    return cell;
}


@end
