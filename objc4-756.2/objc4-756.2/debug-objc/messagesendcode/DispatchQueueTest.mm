//
//  DispatchQueueTest.m
//  testcode
//
//  Created by wqan3313 on 2018/5/31.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import "DispatchQueueTest.h"
#define os_unlikely(x) __builtin_expect(!!x, 0)

typedef struct studentData {
    int age;
    int num;
}studentData;

@implementation DispatchQueueTest


- (void)startTest {
    dispatch_queue_attr_t queue_attr = dispatch_queue_attr_make_with_qos_class (DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY,-1);
    dispatch_queue_t queue = dispatch_queue_create("queue", queue_attr);
    [self testAtomic];
    self.weakObj = [NSObject new];
    _weakObj = [NSObject new];
    self.strongObj = [NSObject new];
    _strongObj = [NSObject new];
    //self.cpObj = [NSObject new];
    _cpObj = [NSObject new];  //weak strong会调用objc_storestrong, objc_storeweak, copy和atomic会调用reallysetproperty， 使用ivar操作变量会丧失copy属性
//    ((void (*)(id, SEL, NSObject *))(void *)objc_msgSend)((id)self, sel_registerName("setWeakObj:"), (NSObject *)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new")));
//    (*(NSObject *__weak *)((char *)self + OBJC_IVAR_$_DispatchQueueTest$_weakObj)) = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"));
//    ((void (*)(id, SEL, NSObject *))(void *)objc_msgSend)((id)self, sel_registerName("setStrongObj:"), (NSObject *)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new")));
//    (*(NSObject *__strong *)((char *)self + OBJC_IVAR_$_DispatchQueueTest$_strongObj)) = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"));
//    ((void (*)(id, SEL, NSObject *))(void *)objc_msgSend)((id)self, sel_registerName("setCpObj:"), (NSObject *)((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new")));
//    (*(NSObject *__strong *)((char *)self + OBJC_IVAR_$_DispatchQueueTest$_cpObj)) = ((NSObject *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSObject"), sel_registerName("new"));
    
    
    @synchronized (nil) {   //不会加锁直接返回
        
    }
}

- (void)testAtomic {
    studentData *data = new studentData();
    int g = 0, p = 3, ov = 3, nv = 3;
    data->age = 5;
    data->num = 7;
    os_atomic_rmw_loop(&p, ov, nv, relaxed, {
        //ov = ov-1;
        nv = nv + 1;
        NSLog(@"os_atomic_rmw_loop, p:%d, ov%d, nv%d", p, ov, nv);
    });
     NSLog(@"os_atomic_rmw_loop, p:%d, ov%d, nv%d", p, ov, nv);
    int ret1 = os_atomic_load(&data->num, relaxed);
    os_atomic_store(&data->num, 11, relaxed);
    int ret2 = os_atomic_xchg(&data->num, 12, relaxed);
    int ret = os_atomic_cmpxchg(&data->age, 5, 10, acquire);
    int ret3 = os_atomic_cmpxchgv(&data->age, 10, 15, &g,acquire);
    int ret4 = os_atomic_add(&p, 10, relaxed);
    int ret5 = os_atomic_add_orig(&p, 10, relaxed);

}

- (void)gcd_dispatch_source_timer {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t begin = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(timer, begin, 2.0 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        //NSLog(@"dispatch_source_set_event_handler !");
    });
    dispatch_resume(timer);
}
@end
