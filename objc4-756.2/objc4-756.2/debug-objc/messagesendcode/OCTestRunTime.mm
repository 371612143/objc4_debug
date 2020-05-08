//
//  OCTestRunTime.m
//  testcode
//
//  Created by wqan3313 on 2018/5/16.
//  Copyright © 2018年 wqan3313. All rights reserved.
//
#import <objc/runtime.h>
#import <objc/message.h>
#import "OCTestRunTime.h"
#import "ObjcHelpFunc.h"

int gotoSchool(id self, SEL _cmd, id value) {
    printf("Friend gotoschool by resolveInstanceMethod!\n");
    return 101;
}

static void gotoSchoolClass(id self, SEL _cmd, id value) {
    //    __FILE__; __LINE__; __func__; __PRETTY_FUNCTION__;
    printf("Friend gotoschool by resolveInstanceMethod!\n");
}

@implementation Friend

+ (void)load {
    //类被加载时候调用  先父类 再子类 再类别 父类只执行一次 (父类load 执行结束才会执行子类load）
    NSLog(@"Friend running fmethod %@", NSStringFromSelector(_cmd));
}

+ (void) initialize {
    //类对象初始化时调用 第一次使用本类 先父类 再子类（每个类只执行一次) 子类没有时会继续调用父类(父类可能执行多次）
    NSLog(@"Friend running fmethod %@", NSStringFromSelector(_cmd));
}

+ (instancetype)alloc {
    NSLog(@"%@ running fmethod %@", [self class], NSStringFromSelector(_cmd));
    return [super alloc];
}

+ (instancetype)new {
    NSLog(@"%@ running fmethod %@", [self class], NSStringFromSelector(_cmd));
    return [super new];
}

- (instancetype)init {
    NSLog(@"%@ running fmethod %@", [self class], NSStringFromSelector(_cmd));
    if (self = [super init]) {
        self.schoolMate = [[Student alloc] init];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"gotoSchool"]) {
        return class_addMethod(self, sel, (IMP)gotoSchool, "i@@:");
    }
    return [super resolveInstanceMethod:sel];
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    NSString *selName = NSStringFromSelector(sel);
    if ([selName isEqualToString:@"canEatRice"]) {
        return class_addMethod([Friend class], sel, (IMP)gotoSchoolClass, "@@:");
    }
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.schoolMate respondsToSelector:aSelector]) {
        return self.schoolMate;
    }
    NSLog(@"%@ can't forwardingTargetForSelector %@", [self class], NSStringFromSelector(aSelector));
    return [super forwardingTargetForSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:"@@:"];
    return sign;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"%@ forwardInvocation by %@", [self class], NSStringFromSelector([anInvocation selector]));
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"%@ doesNotRecognizeSelector %@", [self class], NSStringFromSelector(aSelector));
}
@end

@implementation Student

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(walk)), class_getInstanceMethod(self, @selector(studentWalkWithTeach))); //修改了父类walk的实现 影响到了其他子类的运行 应该用下面的方法
        //swissClassMetod(self, @selector(walk), @selector(studentWalkWithTeach));
    });
    
}

- (void)haveEnglishClass {
    NSLog(@"%@ haveEnglishClass now!", [self class]);
}

-(void)studentWalkWithTeach{
    NSLog(@"studentWalkWithTeach");
}

- (NSInteger)watchMovie:(NSString *)name {
    NSLog(@"%@ watchMovie %@ now!", [self class], name);
    return 0;
}
@end

@implementation OCTestRunTime

+ (void)testMessageSend {
    Friend *oldFriendA = [[Friend alloc] init];
    [oldFriendA hash];
    Friend *newFriendA = [Friend new];
    [newFriendA performSelector:@selector(gotoSchool) withObject:nil];
    [newFriendA haveEnglishClass];
    [newFriendA playComputerGame];
    //[Friend canEatRice];
    newFriendA = [newFriendA init];
    
    Friend *friendb = class_createInstance([Friend class], 64);
    friendb = [friendb init];
    friendb.name = @"zhangsan";
    [friendb setValue:@"zhangsan2" forKey:@"name"];
    Ivar nameVarient = class_getInstanceVariable([Person class], "_name");
    object_setIvar(friendb, nameVarient, @"zhangsan3");
    [friendb haveEnglishClass];

    [[[OCTestRunTime alloc] init] dynamicClass];
    [[[OCTestRunTime alloc] init] ReportFunction];

    Person *laowang = [Person new];
    [laowang walk];
    Student *student = [Student new];
    [student walk];
    [student haveEnglishClass];
    printObjectIvar([Person new]);
    printObjectIvar([NSObject new]);
    [self invokeMethod];
}

+ (void)invokeMethod {
    Student *stu = [Student new];
    Method wacthMetod = class_getInstanceMethod([stu class], NSSelectorFromString(@"watchMovie:"));
    
    [stu watchMovie:@"huanzhugege1"];
    [stu performSelectorOnMainThread:NSSelectorFromString(@"watchMovie:") withObject:@"huanzhugege2" waitUntilDone:YES];
    ((NSInteger(*)(id, SEL, id)) objc_msgSend)(stu, sel_registerName("watchMovie:"), @"huanzhugege3");
    IMP funcPtr = method_getImplementation(wacthMetod);
    ((NSInteger(*)(id, SEL, id)) funcPtr)(stu, @selector(watchMovie:), @"huanzhugege5");
    NSMethodSignature *sig = [NSClassFromString(@"Student") instanceMethodSignatureForSelector:sel_registerName("watchMovie:")];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    invocation.target = stu;
    invocation.selector = @selector(watchMovie:);
    [invocation invoke];
}

- (void)dynamicClass {
    //获取当前程序所有注册的类
    unsigned int outCount;
    Class *classes = objc_copyClassList(&outCount);
//    for (int i = 0; i < outCount; i++) {
//        NSLog(@"%s", class_getName(classes[i]));
//    }
    free(classes);
    
    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    BOOL flag1 = class_addIvar(People, "_name", sizeof(NSString *), log2(sizeof(NSString*)), @encode(NSString*));
    BOOL flag2 = class_addIvar(People, "_age", sizeof(int), sizeof(int), @encode(int));
    flag1 = flag2;
    objc_registerClassPair(People);
    unsigned int varCount;
    Ivar *varList = class_copyIvarList(People, &varCount);
    for (int i = 0; i < varCount; ++i) {
        NSLog(@"%s",ivar_getName(varList[i]));
    }
    free(varList);
    
    id p1 = [[People alloc] init];
    Ivar nameVar = class_getInstanceVariable(People, "_name");
    Ivar ageIvar = class_getInstanceVariable(People, "_age");
    object_setIvar(p1, nameVar, @"lisi");
    object_setIvar(p1, ageIvar, @33);
    NSLog(@"%@",object_getIvar(p1, nameVar));
    NSLog(@"%@",object_getIvar(p1, ageIvar));
}

- (void)ReportFunction {
    //链接：https://www.jianshu.com/p/45fe90253519
    NSLog(@"This object is %p.",self);
    NSLog(@"Class is %@, and super is %@.",[self class],[self superclass]);
    Class currentClass = [self class];
    for( int i = 0; i < 4; ++i )
    {
        NSLog(@"Following the isa pointer %d times gives %p %@",i,currentClass, currentClass);
        currentClass = object_getClass(currentClass);
    }
    NSLog(@"NSObject's class is %p", [NSObject class]);
    NSLog(@"NSObject's meta class is %p",object_getClass([NSObject class]));
}

@end


/*
 runtime 包括了类型定义， 反射， 消息抓发，isa操作
 1.类型  Method Ivar Category protocol Class
 2.对应uruntime 操作及函数
 3.
 */
