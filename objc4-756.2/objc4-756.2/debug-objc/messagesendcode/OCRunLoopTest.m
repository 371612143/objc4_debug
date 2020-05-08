//
//  OCRunLoopTest.m
//  debug-objc
//
//  Created by mac on 2018/9/28.
//

#import "OCRunLoopTest.h"
#import <objc/runtime.h>

@interface WxOperation : NSOperation

@property (nonatomic, strong)NSNumber *cnt;
@property (nonatomic, assign, getter = isExecuting)BOOL executing;
@property (nonatomic, assign, getter = isFinished) BOOL finished;
- (void)completeOperation;
@end

@implementation WxOperation
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithCnt:(NSNumber *)cnt {
    if (self = [super init]) {
        _finished = NO;
        _executing = NO;
        _cnt = cnt;
    }
    return self;
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        self.finished = YES;
        return;
    }
    [self main];
    self.executing = YES;
    NSLog(@"%@, %@, running on%@!", self, NSStringFromSelector(_cmd), [NSThread currentThread]);
    
}

- (void)main {
    //After an operation begins executing, it continues performing its task until it is finished or until your code explicitly cancels the operation
    @try {
        if (self.isCancelled) {
            return;
        }
        self.cnt = @10;
        NSLog(@"%@, %@, running on%@!", self, NSStringFromSelector(_cmd), [NSThread currentThread]);
        [self completeOperation];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }

}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    BOOL automatically = [super automaticallyNotifiesObserversForKey:key];
    return automatically;
}

+ (BOOL)automaticallyNotifiesObserversOfCnt {
    return NO;  //返回yes 不手动释放kvo会崩溃 在kvodelloc
}

- (void)completeOperation {
    self.executing = NO;
    self.finished = YES;
    NSLog(@"%@, %@, running on%@!", self, NSStringFromSelector(_cmd), [NSThread currentThread]);
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isReady {
    //be sure to call super from your isReady method if you still support the default dependency management system provided by the NSOperation class
    return [super isReady];
}
@end

@interface OCRunLoopTest()
@property (nonatomic, strong)NSOperationQueue *queue;
@property (nonatomic, assign)NSInteger currentTicket;
@property (nonatomic, assign)dispatch_semaphore_t semaphore;
@end

@implementation OCRunLoopTest

- (instancetype)init {
    if (self = [super init]) {
        self.currentTicket = 100;
        self.semaphore = dispatch_semaphore_create(1);
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 3;
        [self runInqueue];
        [self startThread];
    }
    return self;
}

- (void)runInqueue {
    //https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation1 with:%@", [NSThread currentThread]);
    }];// number = 2 操作较多时会调度到其他线程 一般在主线程执行
    [blockOperation addExecutionBlock:^{
        NSLog(@"NSBlockOperation1 addExecutionBlock with:%@", [NSThread currentThread]);
    }];
    //you can add more blocks as needed later. When it comes time to execute an NSBlockOperation object, the object submits all of its blocks to the default-priority, concurrent dispatch queue. The object then waits until all of the blocks finish executing
    
    NSInvocationOperation *invocationA = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationMethod:) object:@"invocationA"];
    //You should always configure dependencies before running your operations or adding them to an operation queue. Dependencies added afterward may not prevent a given operation object from running.
    //Dependencies rely on each operation object sending out appropriate KVO notifications whenever the status of the object changes.
    blockOperation.queuePriority = NSOperationQueuePriorityVeryLow;
    invocationA.queuePriority = NSOperationQueuePriorityNormal;  //isready 大于优先级
    [invocationA addDependency:blockOperation]; //添加依赖后会在所有的依赖operation执行完后再执行
    
    NSInvocationOperation *saleA = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saleTicket:) object:@"saleA"];
    
    NSInvocationOperation *saleB = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(saleTicket:) object:@"saleB"];
    WxOperation *wxOperation = [WxOperation new];
    [wxOperation addObserver:self forKeyPath:@"cnt" options:NSKeyValueObservingOptionNew context:nil]; //NSKVODeallocate.onceToken
    [invocationA addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
    
    WxOperation *customOp = [WxOperation new];
    [customOp addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew context:nil];
    [customOp start];
    
    Class cls = object_getClass(wxOperation); //isFinished WxOperation  cnt NSKVONotifying_WxOperation 会崩溃
    Class clsw = object_getClass(customOp);  //wxOperation finished isFinished operation status,callback,
    Class clss = object_getClass(invocationA); //NSInvocationOperation dependcy priroty
    // instances of the NSOperation class consume memory and have real costs associated with their execution.
    //You should also avoid adding large numbers of operations to a queue all at once, or avoid continuously adding operation objects to a queue faster than they can be processed.As one batch finishes executing, use a completion block to tell your application to create a new batch
    [self.queue addOperation:wxOperation];
    [self.queue addOperation:saleA];
    [self.queue addOperation:saleB];
    [self.queue addOperation:blockOperation];
    [self.queue addOperation:invocationA];  //_dispatch_root_queue_drain
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.queue cancelAllOperations];  //有可能取消正在执行的操作 cancel需要在main中手动监听
        //操作开始执行后，它将继续执行其任务，直到完成或直到您的代码明确取消操作。即使在操作开始执行之前，也可以随时取消。尽管该NSOperation课程为客户提供了取消操作的方法，但必须自愿识别取消事件。如果操作被彻底终止，则可能无法回收已分配的资源。因此，操作对象应检查取消事件，并在操作过程中发生时正常退出。
        [self.queue setSuspended:YES]; //无法取消正在执行的操作
        //Suspending a queue does not cause already executing operations to pause in the middle of their tasks. It simply prevents new operations from being scheduled for execution. You might suspend a queue in response to a user request to pause any ongoing work, because the expectation is that the user might eventually want to resume that work.
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"observeValueForKeyPath %@ %@ %@",keyPath, object, change); //new = 1
}

- (void)invocationMethod:(NSString *)operatorId {
    NSLog(@"self.currentTicket:%ld %@ %@", self.currentTicket, operatorId, [NSThread currentThread]);
}

- (void)saleTicket:(NSString *)operatorId {
    while (true) {
        long result = dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, 2.0*NSEC_PER_SEC));
        //sleep(3); //80 79 77 78 75 76 x超时后将会释放锁 造成线程不安全
        if (self.currentTicket > 0) {  //不要用小于0 因为另外线程
            self.currentTicket = self.currentTicket - 1;
            [NSThread sleepForTimeInterval:1.0f];
            //NSLog(@"self.currentTicket:%ld %@ %@", self.currentTicket, operatorId, [NSThread currentThread]);
        }
        else {
            long sresult = dispatch_semaphore_signal(self.semaphore);
            break;
        }
        long sresult = dispatch_semaphore_signal(self.semaphore);
    }
    
}

#pragma mark runloop
- (void)startThread {
    self.threadA = [[NSThread alloc] initWithTarget:self selector:@selector(threadAMethod) object:nil];
    self.threadB = [[NSThread alloc] initWithTarget:self selector:@selector(threadBMethod) object:nil];
    self.threadC = [[NSThread alloc] initWithTarget:self selector:@selector(threadCMethod:) object:@3];
    self.threadA.name = @"threadA";
    self.threadB.name = @"threadB";
    self.threadC.name = @"threadC";
    [self.threadC start];
    [self.threadB start];
    [self.threadA start];
    
}

- (void)threadAMethod {
    //只有timer和source 才能确保线程常驻
    CFRunLoopActivity flags = kCFRunLoopAllActivities;
    CFRunLoopRef rl = CFRunLoopGetCurrent();
    CFRunLoopObserverRef runLoopObserverRef = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, flags, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"threadAMethod %ld", activity); //1 2 4 128 1 2 4 32 64 2 4 32 64 128  一直调用runbeforedate 所以会有多次进入
    });
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserverRef, kCFRunLoopCommonModes);
    [self performSelector:@selector(threadPerformanctTest:) withObject:@"A afterDelay" afterDelay:1.0f];
    [self performSelector:@selector(threadPerformanctTest:) onThread:self.threadC withObject:@"A onThread:self.threadC waitUntilDone:NO" waitUntilDone:NO];
    NSTimer *timeA = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"threadAMethod scheduledTimerWithTimeInterval1");
    }];
    CFRunLoopTimerRef cfTimer = (__bridge CFRunLoopTimerRef)timeA;
    CFRunLoopAddTimer(rl, cfTimer, kCFRunLoopCommonModes);
    CFRunLoopRun();

}

- (void)threadBMethod {
    NSLog(@"threadBMethod");
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [self performSelector:@selector(threadPerformanctTest:) withObject:@"B afterDelay" afterDelay:1.0f];
    CFRunLoopActivity flags = kCFRunLoopAllActivities;
    CFRunLoopObserverRef runLoopObserverRef = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, flags, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"%ld", activity); //1 2 4 128 1 2 4 32 64 2 4 32 64 128  一直调用runbeforedate 所以会有多次进入
    });
    
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserverRef, kCFRunLoopCommonModes);
    [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];


}

- (void)threadCMethod:(id)param {
    NSLog(@"threadCMethod");
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    [runloop run];
}

- (void)threadPerformanctTest:(NSString*)indenfity {
    NSLog(@"%@", indenfity);

}
@end
