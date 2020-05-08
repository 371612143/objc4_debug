//
//  WxKvcTestClass.m
//  testcode
//
//  Created by wqan3313 on 2018/6/28.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import "WxKvcTestClass.h"
#include <objc/runtime.h>


//The key-value observing addObserver:forKeyPath:options:context: method does not maintain strong references to the observing object, the observed objects, or the context. You should ensure that you maintain strong references to the observing, and observed, objects, and the context as necessary.

/*
 When removing an observer, keep several points in mind:
 
 Asking to be removed as an observer if not already registered as one results in an NSRangeException. You either call removeObserver:forKeyPath:context: exactly once for the corresponding call to addObserver:forKeyPath:options:context:, or if that is not feasible in your app, place the removeObserver:forKeyPath:context: call inside a try/catch block to process the potential exception.
 An observer does not automatically remove itself when deallocated. The observed object continues to send notifications, oblivious to the state of the observer. However, a change notification, like any other message, sent to a released object, triggers a memory access exception. You therefore ensure that observers remove themselves before disappearing from memory.
 The protocol offers no way to ask an object if it is an observer or being observed. Construct your code to avoid release related errors. A typical pattern is to register as an observer during the observer’s initialization (for example in init or viewDidLoad) and unregister during deallocation (usually in dealloc), ensuring properly paired and ordered add and remove messages, and that the observer is unregistered before it is freed from memory.
 observer 在之前版本用assign后面用weak保存。一次注册一次释放，释放未注册或多次释放observer会导致异常 观察者不会自动移除，当观察者没有strong引用对象后会释放，但是注册的观察者可能没有被置空，导致指针悬浮但是还会持续受到消息，导致异常。
 1.指针悬浮 对象释放没有置空 exc_bad_access
 2.野指针 指针未初始化 exc_bad_access
 3.空指针 null 返回0 null
 4.zombie对象 (没有引用却再内存中不被释放）内存泄漏
 5.内存碎片（malloc） 比内存泄漏更难处理
 */



@interface WxKvoTestClass : NSObject
@property (nonatomic, strong)NSString *name;
@property (nonatomic, strong)NSMutableArray *subList;
@property (nonatomic, strong)NSString *firstName;
@property (nonatomic, strong)NSString *lastName;
@property (nonatomic, strong)NSMutableString *manualStr;
@property (nonatomic, strong)id observer;
@end

@implementation WxKvoTestClass



- (instancetype)initWithObserver:(id)observer {
    if (self = [super init]) {
        _name = @"bruce li";
        _firstName = @"bruce";
        _lastName = @"li";
        _subList = [[NSMutableArray alloc] initWithObjects:@1, nil];
        [self setObserver:observer];
    }
    return self;
}

- (void)setObserver:(id)observer {
    _observer = observer;
    Class cls =  object_getClass(self);
    [self addObserver:observer forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"subList" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:observer forKeyPath:@"manualStr" options:NSKeyValueObservingOptionNew context:nil];
    Class ncls =  object_getClass(self);
    printClassMethods(ncls);
    //setSubList setName class _isKVOA dealloc
    NSLog(@"WxKvcTestClass isa:%@, supper class:%@", object_getClass(self),
          class_getSuperclass(object_getClass(self)));
}

+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"manualStr"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}

- (void)setManualStr:(NSMutableString *)manualStr {
    [self willChangeValueForKey:@"manualStr"];
    _manualStr = manualStr;
    [self didChangeValueForKey:@"manualStr"];
}

- (void)willChangeValueForKey:(NSString *)key {
    [super willChangeValueForKey:key];
}

- (void)didChangeValueForKey:(NSString *)key {
    [super didChangeValueForKey:key];
}

- (id)valueForKey:(NSString *)key {
    return [super valueForKey:key];
}

- (void)dealloc {
    [self removeObserver:_observer forKeyPath:@"name"];
    [self removeObserver:_observer forKeyPath:@"manualStr"];
    [self removeObserver:_observer forKeyPath:@"subList"];
}
@end


@interface WxKvcTestClass()
@property (nonatomic, strong)NSNumber *_uid;  //将_uid声明到uid后面 _uid属性会被覆盖 编译时先生成_uid 不会生成__uid
@property (nonatomic, strong)NSNumber *uid;
@property (nonatomic, strong)NSNumber *name1;
@property (nonatomic, assign)NSInteger age;
@end



@implementation WxKvcTestClass
@synthesize _uid = _userId;

+ (void)startTest {
    WxKvcTestClass *kvcTest = [[self alloc] init];
//    [kvcTest setValue:@"zhangsan" forKey:@"name"];
//    [kvcTest setValue:@"lisi" forKey:@"name"];
//    [kvcTest setValue:@123 forKey:@"_uid"];
//    [kvcTest setValue:nil forKey:@"uid"]; //不会触发setNilValueForKey
//    [kvcTest setValue:@123 forKey:@"uid"];
//    [kvcTest setValue:@1234 forKey:@"_uid"];
//    [kvcTest setValue:@"aa" forKey:@"name"];
//    [kvcTest setValue:nil forKey:@"age"];
    
    WxKvoTestClass *kvoTest = [[WxKvoTestClass alloc] initWithObserver:kvcTest];
    kvoTest.name = @"Jhon li"; //_NSSetObjectValueAndNotify NSKeyValueDidChangeBySetting
    [kvoTest.subList addObject:@1]; //不会触发
    [[kvoTest mutableArrayValueForKeyPath:@"subList"] addObject:@2];
    [[kvoTest mutableArrayValueForKeyPath:@"subList"] addObject:@"rose"];
    //kvoTest.manualStr = @"manualStr"; //Attempt to mutate immutable object with appendFormat:'
    kvoTest.manualStr = [NSMutableString stringWithFormat:@"manualStr"];
    [kvoTest.manualStr appendFormat:@"2"];
    //[NSKeyValueNotifyingMutableArray addObject:] NSKeyValueWillChangeByOrderedToManyMutation
    //indexes = "<_NSCachedIndexSet: 0x100b5a430>[number of indexes: 1 (in 1 ranges), indexes: (2)]";

}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"observeValueForKeyPath:%@ value changed:%@", keyPath, change);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"%@:error 属性不存在:%@", NSStringFromSelector(_cmd), key);
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"%@:error 属性不存在:%@", NSStringFromSelector(_cmd), key);
}

- (void)setNilValueForKey:(NSString *)key {
    NSLog(@"%@:error 属性错误:%@", NSStringFromSelector(_cmd), key);
}

- (void)set_uid:(NSNumber *)_uid {
    Ivar _uidVar = class_getInstanceVariable([self class], "__uid");
    object_setIvar(self, _uidVar, _uid);
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return [super automaticallyNotifiesObserversForKey:key];
}

@end
/*程定义，还是在类实现处定义，也无论用了什么样的访问修饰符，只在存在以_<key>命名的变量，KVC都可以对该成员变量赋值。
set<key>：方法，也没有_<key>成员变量，KVC机制会搜索_is<Key>的成员变量。
 和上面一样，如果该类即没有set<Key>：方法 (BOOL)accessInstanceVariablesDirectly ，_<key>和_is<Key>,<key>和is<Key>的成员变量。再给它们赋值。
 如果上面列出的方法或者成员变量都不存在，系统将会执行该对象的setValue：forUndefinedKey：方法，默认是抛出异常。
 
 首先按get<Key>,<key>,is<Key>的顺序方法查找getter方法，找到的话会直接调用。(BOOL)accessInstanceVariablesDirectly ，_<key>和_is<Key>,<key>和is<Key>的成员变量

 */
