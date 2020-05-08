//
//  OcBlockTest.m
//  debug-objc
//
//  Created by mac on 2018/9/30.
//
#import "OcBlockTest.h"
#import "Person.h"

static NSInteger gs_countBlockRef = 1;

//block,delegate,notification,KVO的回调当中,哪一些是同步,会阻塞当前线程
@interface OcBlockTest()
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)onAnimationFinishedBlock finishedBlock;
@property (nonatomic, assign)NSInteger age;
@property (atomic, strong)NSNumber *atomicData;

@property (nonatomic, copy)NSArray *mcopyArray;  //copy属性对象都是不可变,copy strong, weak 只能修饰oc对象
@property (atomic, strong)NSMutableArray *mutableArray;  //atomic 不能保证a集合insert add removeobject操作安全
@property (atomic, assign)NSInteger atomicInt;
@property (nonatomic, copy)NSString *strCopy;
@property (nonatomic, strong)NSString *strStrong;
@property (nonatomic, copy)NSMutableString *mstrCopy;
@property (nonatomic, weak)NSObject *weakObj;
@end

@implementation OcBlockTest

+ (void)startTest {
    OcBlockTest *test = [self new];
    [test doBlockTest];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [test testStackParam];  //Thread 1: EXC_BAD_ACCESS (code=1, address=0x2)
    });
    [test testStackParam];
    [test testCopy];
    [test testAtomicData];
}

- (void)doBlockTest {
    @autoreleasepool {
        NSInteger autoParams = 1;  //0x7ffeefbff518
        NSInteger *pAuto = &autoParams; //0x7ffeefbff510
        __block NSInteger __blockParamC = 2;  //使用block将变量copy到了堆区 0x100f001d8
        static NSInteger lsi = 3;;
        NSString *wekStr = @"1xxx";
        NSString *bStr = @"woshixiao";
        NSMutableString *mutableStr = [NSMutableString stringWithFormat:@"fsd d wwww"];
        /*struct __OcBlockTest__doBlockTest_block_impl_2 {
            struct __block_impl impl;
            struct __OcBlockTest__doBlockTest_block_desc_2* Desc;
            NSInteger *lsi;
            __weak typeof (&*self) weakSelf;
            NSInteger *pAuto;
            NSString *__strong bStr;
            NSMutableString *__strong mutableStr;
            __Block_byref___blockParamC_0 *__blockParamC; // by ref
            __OcBlockTest__doBlockTest_block_impl_2(void *fp, struct __OcBlockTest__doBlockTest_block_desc_2 *desc, NSInteger *_lsi, __weak typeof (&*self) _weakSelf, NSInteger *_pAuto, NSString *__strong _bStr, NSMutableString *__strong _mutableStr, __Block_byref___blockParamC_0 *___blockParamC, int flags=0) : lsi(_lsi), weakSelf(_weakSelf), pAuto(_pAuto), bStr(_bStr), mutableStr(_mutableStr), __blockParamC(___blockParamC->__forwarding) {
                impl.isa = &_NSConcreteStackBlock;
                impl.Flags = flags;
                impl.FuncPtr = fp;
                Desc = desc;
            }
        };
        static void __OcBlockTest__doBlockTest_block_func_2(struct __OcBlockTest__doBlockTest_block_impl_2 *__cself, int a, int b) {
            __Block_byref___blockParamC_0 *__blockParamC = __cself->__blockParamC; // bound by ref
            NSInteger *lsi = __cself->lsi; // bound by copy
            __weak typeof (&*self) weakSelf = __cself->weakSelf; // bound by copy
            NSInteger *pAuto = __cself->pAuto; // bound by copy
            NSString *__strong bStr = __cself->bStr; // bound by copy
            NSMutableString *__strong mutableStr = __cself->mutableStr; // bound by copy
            
            
            
            NSInteger count = a + b;
            (__blockParamC->__forwarding->__blockParamC) = 3;
            gs_countBlockRef = 4;
            (*lsi) = 4;
            ((void (*)(id, SEL, NSString *))(void *)objc_msgSend)((id)weakSelf, sel_registerName("setName:"), (NSString *)&__NSConstantStringImpl__var_folders_59_w44gdrmx5g102xhc2qjv1z6m0000gp_T_OcBlockTest_5fc691_mi_6);
            ((void (*)(id, SEL, NSInteger))(void *)objc_msgSend)((id)weakSelf, sel_registerName("setAge:"), (NSInteger)4);
            NSLog((NSString *)&__NSConstantStringImpl__var_folders_59_w44gdrmx5g102xhc2qjv1z6m0000gp_T_OcBlockTest_5fc691_mi_7, &pAuto, &(__blockParamC->__forwarding->__blockParamC), bStr, mutableStr);
        }
        static void __OcBlockTest__doBlockTest_block_copy_2(struct __OcBlockTest__doBlockTest_block_impl_2*dst, struct __OcBlockTest__doBlockTest_block_impl_2*src) {_Block_object_assign((void*)&dst->__blockParamC, (void*)src->__blockParamC, 8);_Block_object_assign((void*)&dst->weakSelf, (void*)src->weakSelf, 3/);_Block_object_assign((void*)&dst->bStr, (void*)src->bStr, 3);_Block_object_assign((void*)&dst->mutableStr, (void*)src->mutableStr, 3/);}
        
        static void __OcBlockTest__doBlockTest_block_dispose_2(struct __OcBlockTest__doBlockTest_block_impl_2*src) {_Block_object_dispose((void*)src->__blockParamC, 8);_Block_object_dispose((void*)src->weakSelf, 3);_Block_object_dispose((void*)src->bStr, 3);_Block_object_dispose((void*)src->mutableStr, 3);}*/
        __weak typeof(&*self) weakSelf = self;
        onAnimationFinishedBlock blockA = ^(int a, int b) {
            *pAuto = 2;
            //autoParams = 3; //Variable is not assignable (missing __block type specifier)
            NSInteger count = a + b;
            __blockParamC = 3;
            gs_countBlockRef = 4;
            lsi = 4;
            weakSelf.name = @"xxx";
            weakSelf.age = 4;
            NSLog(@"pAuto address: %p,__blockParamC address: %p, bStr %p,mutableStr %p", &pAuto, &__blockParamC, bStr, mutableStr);
        }; //__NSStackBlock__  block 作为右值被传递时编译器在arc模式下会自动对其执行拷贝操作到堆区（作为函数返回值，参数，被强引用
        //使用weak对象修饰block 照样为stackblock 不会调用block_copy
        onAnimationFinishedBlock blockB = ^(int a, int b) {
            gs_countBlockRef = 4;
        };  //__NSGlobalBlock__
        blockA(3, 5);
        //((void (*)(__block_impl *, int, int))((__block_impl *)blockA)->FuncPtr)((__block_impl *)blockA, 3, 5);
        NSLog(@"pAuto address: %p,__blockParamC address: %p, bStr %p,mutableStr %p", &pAuto, &__blockParamC, bStr, mutableStr);
        
        self.finishedBlock = ^(int a, int b) {
            //*pAuto = 2;  //Thread 1: EXC_BAD_ACCESS (code=1, address=0x2)  栈区释放后 内存访问出错
            //autoParams = 3; //Variable is not assignable (missing __block type specifier)
            NSInteger count = a + b;
            __blockParamC = 3;
            gs_countBlockRef = 4;
            lsi = 4;
            weakSelf.name = @"xxx";
            weakSelf.age = 4;
            NSLog(@"pAuto address: %p,__blockParamC address: %p, bStr %p,mutableStr %p", &pAuto, &__blockParamC, bStr, mutableStr);
        };
        onAnimationFinishedBlock blockRef = self.finishedBlock;
        onAnimationFinishedBlock blockRef2 = [self.finishedBlock copy]; //0x00000001000036e0 0x00000001000036e0 0x00000001000036e0 0x00000001000036e0 引用计数始终为1 对堆区block copy 和引用
        __weak onAnimationFinishedBlock weakBlock = blockRef; //会自动置空 虽然引用计数打印值为1 但还是会对内存进行引用计数管理
        printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(blockRef))); //1
        blockRef = blockRef2  = nil;
        //self.finishedBlock = nil;
        __weak onAnimationFinishedBlock weakBlockb = ^(int a, int b){  //__NSStackBlock__调用objc_initweak 不会触发copy
            __blockParamC = 4;
        };
        
        onAnimationFinishedBlock globalBlocka = ^(int a, int b){
        };
        
        onAnimationFinishedBlock globalBlockb = ^(int a, int b){
        };
        NSLog(@"%@ %p %p", ^{NSLog(@"%ld",autoParams);}, globalBlocka, globalBlockb);  //__NSStackBlock__
    }

}

- (void)testStackParam {
    NSInteger paramA = 6, paramB = 8;
    if (self.finishedBlock) {
        self.finishedBlock(paramA, paramB);
    }
    self.finishedBlock = nil;
}

- (void)dealloc {
    self.finishedBlock = nil;
}

- (void)testCopy {
    self.weakObj = [NSObject new];
    _weakObj = [NSObject new];
//    static NSObject * _I_DispatchQueueTest_weakObj(DispatchQueueTest * self, SEL _cmd) { return (*(NSObject *__weak *)((char *)self + OBJC_IVAR_$_DispatchQueueTest$_weakObj)); }
//    static void _I_DispatchQueueTest_setWeakObj_(DispatchQueueTest * self, SEL _cmd, NSObject *weakObj) { (*(NSObject *__weak *)((char *)self + OBJC_IVAR_$_DispatchQueueTest$_weakObj)) = weakObj; }
    NSString *p1 = [NSString stringWithFormat:@"NSString"];
    NSMutableString *p2 = [NSMutableString stringWithFormat:@"contentdata"];
    //NSMutableString *cast_str = p1;  //编译时通过 运行时有问题
    //NSString *constcast_str = p2;
    self.strCopy = p2;
    self.strStrong = p2;
    self.mstrCopy = p2;
    //NSLog(@"p2:%p strCopy:%p %@ strStrong:%p %@", p2, self.strCopy, self.strCopy, self.strStrong, self.strStrong);
    //p2:0x100a13980 strCopy:0x386b2016452088b5 contentdata strStrong:0x100a13980 contentdata
    [p2 appendString:@"1111"];
    //NSLog(@"p2:%p strCopy:%p %@ strStrong:%p %@", p2, self.strCopy, self.strCopy, self.strStrong, self.strStrong);
    //p2:0x100a13980 strCopy:0x386b2016452088b5 contentdata strStrong:0x100a13980 contentdata1111
    //[self.mstrCopy appendString:@"333"];
    //[NSTaggedPointerString appendString:]: unrecognized selector sent to instance 0x386b2016452088b5'
    
    unsigned long strRefCount = CFGetRetainCount((__bridge CFTypeRef)p1);
    unsigned long str2RefCount = CFGetRetainCount((__bridge CFTypeRef)p2);
    NSMutableArray *arr1 = [NSMutableArray arrayWithObjects:p1, @4, @5, nil];
    NSMutableArray *arr2 = [NSMutableArray arrayWithObjects:p2, @4, @5, nil];
    unsigned long copyRefCount1 = CFGetRetainCount((__bridge CFMutableArrayRef)arr1);
    unsigned long mutableRefCount1 = CFGetRetainCount((__bridge CFMutableArrayRef)arr2);
    
    self.mcopyArray = arr1;   //__NSArrayI 所有copy对象都是不可变的  所有nsusedrfalut存储数据都是不可变 的
    self.mutableArray = arr2;
    unsigned long copyRefCount = CFGetRetainCount((__bridge CFMutableArrayRef)self.mcopyArray);
    unsigned long mutableRefCount = CFGetRetainCount((__bridge CFMutableArrayRef)self.mutableArray);
    strRefCount = CFGetRetainCount((__bridge CFMutableStringRef)p1);
    str2RefCount = CFGetRetainCount((__bridge CFMutableStringRef)p2);
    NSLog(@"str:%p arr1:%p, copyarr1:%p", p1, arr1[0], self.mcopyArray[0]);
    NSLog(@"str2:%p arr2:%p, mutableArray:%p", p2, arr2[0], self.mutableArray[0]);
    //[self.mcopyArray addObject:@4]; //会崩溃 [NSObject(NSObject) doesNotRecognizeSelector:] [__NSArrayI addObject:]: unrecognized selector sent to instance 0x100a55650
}

- (void)testAtomicData {
    self.name = [NSMutableString stringWithFormat:@"aaa"];
    self.atomicInt = 5;  //此处不会调用realysetproperty 把数据载入内存只需要一条汇编指令属于原子操作
    NSLog(@"%p", self.name);
    self.atomicData = @3;
    _atomicData = @5.7f;
    _atomicData = @1.3f;
    //    (*(NSNumber **)((char *)self + OBJC_IVAR_$_OcBlockTest$_atomicData)) = ((NSNumber *(*)(Class, SEL, float))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithFloat:"), 5.69999981F);
    //    (*(NSNumber **)((char *)self + OBJC_IVAR_$_OcBlockTest$_atomicData)) = ((NSNumber *(*)(Class, SEL, float))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithFloat:"), 1.29999995F);
    //使用成员变量直接赋值时直接对self+ivatr.offset 内存赋值不会调用其他方法
    //所以atomic对象不是线程安全的，他只保证realysetropety get set方法执行的原子性
    //无法保证直接使用ivar, objc_setivar 容器类成员insert add remove get方法安全 无法保证使用时得到期望值 self.a = self.a+1
    NSNumber *num = _atomicData;
    NSNumber *number2 = num;
    NSNumber *number23 = num;
    //NSLog(@"_atomicData:%p num:%p number2:%p number23:%p", _atomicData, num, number2, number23);  //0X627 taggedpoint
    NSMutableString *CFStr = [NSMutableString stringWithFormat:@"a"]; //CFString
    NSString *taggedpointStr = [NSString stringWithFormat:@"a"];  //NSTaggedPointerString
    NSString *taggedpointStr2 = [taggedpointStr copy]; //NSTaggedPointerString
    NSMutableString *taggedpointStr3 = [taggedpointStr mutableCopy]; //CFString
    self.name = [taggedpointStr copy]; //NSTaggedPointerString
    //NSLog(@"%p %p %p", taggedpointStr, taggedpointStr2, self.fatherName); //0x6115 0x6115 0x6115 0x00007ffeefbff468 0x00007ffeefbff460 0x0000000101e1e828 从引用计数可以看出，这个是一个释放不掉的单例常量对象。在运行时根据实际情况创建。
}

@end
/*
 直接访问栈上内存地址栈释放后会出错
 对于非对象的变量来说，自动变量的值，被copy进了Block，不带__block的自动变量只能在里面被访问，并不能改变值。
 带__block的自动变量 和 静态变量 就是直接地址访问。所以在Block里面可以直接改变变量的值。
 而剩下的静态全局变量，全局变量，函数参数，也是可以在直接在Block中改变变量值的，但是他们并没有变成Block结构体__main_block_impl_0的成员变量，因为他们的作用域大，所以可以直接更改他们的值。值得注意的是，静态全局变量，全局变量，函数参数他们并不会被Block持有，也就是说不会增加retainCount值。对于对象来说，在MRC环境下，__block根本不会对指针所指向的对象执行copy操作，而只是把指针进行的复制。而在ARC环境下，对于声明为__block的外部对象，在block内部会进行retain，以至于在block环境内能安全的引用外部对象。
 
 */

//static void _I_OcBlockTest_doBlockTest(OcBlockTest * self, SEL _cmd) {
//    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool;
//        NSInteger autoParams = 1;
//        NSInteger *pAuto = &autoParams;
//        __attribute__((__blocks__(byref))) __Block_byref___blockParamC_0 __blockParamC = {(void*)0,(__Block_byref___blockParamC_0 *)&__blockParamC, 0, sizeof(__Block_byref___blockParamC_0), 2};
//        static NSInteger lsi = 3;;
//        onAnimationFinishedBlock blockA = ((void (*)(int, int))&__OcBlockTest__doBlockTest_block_impl_0((void *)__OcBlockTest__doBlockTest_block_func_0, &__OcBlockTest__doBlockTest_block_desc_0_DATA, pAuto, &lsi, self, (__Block_byref___blockParamC_0 *)&__blockParamC, 570425344));
//        onAnimationFinishedBlock blockB = ((void (*)(int, int))&__OcBlockTest__doBlockTest_block_impl_1((void *)__OcBlockTest__doBlockTest_block_func_1, &__OcBlockTest__doBlockTest_block_desc_1_DATA));
//        ((void (*)(__block_impl *, int, int))((__block_impl *)blockA)->FuncPtr)((__block_impl *)blockA, 3, 5);
//        ((void (*)(id, SEL, onAnimationFinishedBlock))(void *)objc_msgSend)((id)self, sel_registerName("setFinishedBlock:"), ((void (*)(int, int))&__OcBlockTest__doBlockTest_block_impl_2((void *)__OcBlockTest__doBlockTest_block_func_2, &__OcBlockTest__doBlockTest_block_desc_2_DATA, pAuto, &lsi, self, (__Block_byref___blockParamC_0 *)&__blockParamC, 570425344)));
//        NSLog((NSString *)&__NSConstantStringImpl__var_folders__w_0ds8n5890rz671pxt7jlgb_m0000gn_T_OcBlockTest_69e3df_mi_2, ((void (*)())&__OcBlockTest__doBlockTest_block_impl_3((void *)__OcBlockTest__doBlockTest_block_func_3, &__OcBlockTest__doBlockTest_block_desc_3_DATA, autoParams)));
//    }
//
//}
//
//
//static void _I_OcBlockTest_testStackParam(OcBlockTest * self, SEL _cmd) {
//    NSInteger paramA = 6, paramB = 8;
//    if (((onAnimationFinishedBlock (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("finishedBlock"))) {
//        ((onAnimationFinishedBlock (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("finishedBlock"))(paramA, paramB);
//    }
//}
//
//static NSString * _I_OcBlockTest_name(OcBlockTest * self, SEL _cmd) { return (*(NSString **)((char *)self + OBJC_IVAR_$_OcBlockTest$_name)); }
//extern "C" __declspec(dllimport) void objc_setProperty (id, SEL, long, id, bool, bool);
//
//static void _I_OcBlockTest_setName_(OcBlockTest * self, SEL _cmd, NSString *name) { objc_setProperty (self, _cmd, __OFFSETOFIVAR__(struct OcBlockTest, _name), (id)name, 0, 1); }
//
//static void(* _I_OcBlockTest_finishedBlock(OcBlockTest * self, SEL _cmd) )(int, int){ return (*(onAnimationFinishedBlock *)((char *)self + OBJC_IVAR_$_OcBlockTest$_finishedBlock)); }
//static void _I_OcBlockTest_setFinishedBlock_(OcBlockTest * self, SEL _cmd, onAnimationFinishedBlock finishedBlock) { objc_setProperty (self, _cmd, __OFFSETOFIVAR__(struct OcBlockTest, _finishedBlock), (id)finishedBlock, 0, 1); }
//
//static NSString * _I_OcBlockTest_fatherName(OcBlockTest * self, SEL _cmd) { return (*(NSString **)((char *)self + OBJC_IVAR_$_OcBlockTest$_fatherName)); }
//static void _I_OcBlockTest_setFatherName_(OcBlockTest * self, SEL _cmd, NSString *fatherName) { (*(NSString **)((char *)self + OBJC_IVAR_$_OcBlockTest$_fatherName)) = fatherName; }
//
//static NSInteger _I_OcBlockTest_age(OcBlockTest * self, SEL _cmd) { return (*(NSInteger *)((char *)self + OBJC_IVAR_$_OcBlockTest$_age)); }
//static void _I_OcBlockTest_setAge_(OcBlockTest * self, SEL _cmd, NSInteger age) { (*(NSInteger *)((char *)self + OBJC_IVAR_$_OcBlockTest$_age)) = age; }
//// @end
//
//struct _prop_t {
//    const char *name;
//    const char *attributes;
//};
//
//struct _protocol_t;
//
//struct _objc_method {
//    struct objc_selector * _cmd;
//    const char *method_type;
//    void  *_imp;
//};
//
//struct _protocol_t {
//    void * isa;  // NULL
//    const char *protocol_name;
//    const struct _protocol_list_t * protocol_list; // super protocols
//    const struct method_list_t *instance_methods;
//    const struct method_list_t *class_methods;
//    const struct method_list_t *optionalInstanceMethods;
//    const struct method_list_t *optionalClassMethods;
//    const struct _prop_list_t * properties;
//    const unsigned int size;  // sizeof(struct _protocol_t)
//    const unsigned int flags;  // = 0
//    const char ** extendedMethodTypes;
//};
//
//struct _ivar_t {
//    unsigned long int *offset;  // pointer to ivar offset location
//    const char *name;
//    const char *type;
//    unsigned int alignment;
//    unsigned int  size;
//};
//
//struct _class_ro_t {
//    unsigned int flags;
//    unsigned int instanceStart;
//    unsigned int instanceSize;
//    unsigned int reserved;
//    const unsigned char *ivarLayout;
//    const char *name;
//    const struct _method_list_t *baseMethods;
//    const struct _objc_protocol_list *baseProtocols;
//    const struct _ivar_list_t *ivars;
//    const unsigned char *weakIvarLayout;
//    const struct _prop_list_t *properties;
//};
//
//struct _class_t {
//    struct _class_t *isa;
//    struct _class_t *superclass;
//    void *cache;
//    void *vtable;
//    struct _class_ro_t *ro;
//};
//
//struct _category_t {
//    const char *name;
//    struct _class_t *cls;
//    const struct _method_list_t *instance_methods;
//    const struct _method_list_t *class_methods;
//    const struct _protocol_list_t *protocols;
//    const struct _prop_list_t *properties;
//};
//extern "C" __declspec(dllimport) struct objc_cache _objc_empty_cache;
//#pragma warning(disable:4273)
//
//extern "C" unsigned long int OBJC_IVAR_$_OcBlockTest$_name __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct OcBlockTest, _name);
//extern "C" unsigned long int OBJC_IVAR_$_OcBlockTest$_finishedBlock __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct OcBlockTest, _finishedBlock);
//extern "C" unsigned long int OBJC_IVAR_$_OcBlockTest$_fatherName __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct OcBlockTest, _fatherName);
//extern "C" unsigned long int OBJC_IVAR_$_OcBlockTest$_age __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct OcBlockTest, _age);
//
//static struct /*_ivar_list_t*/ {
//    unsigned int entsize;  // sizeof(struct _prop_t)
//    unsigned int count;
//    struct _ivar_t ivar_list[4];
//} _OBJC_$_INSTANCE_VARIABLES_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_const"))) = {
//    sizeof(_ivar_t),
//    4,
//    {{(unsigned long int *)&OBJC_IVAR_$_OcBlockTest$_name, "_name", "@\"NSString\"", 3, 8},
//        {(unsigned long int *)&OBJC_IVAR_$_OcBlockTest$_finishedBlock, "_finishedBlock", "@?", 3, 8},
//        {(unsigned long int *)&OBJC_IVAR_$_OcBlockTest$_fatherName, "_fatherName", "@\"NSString\"", 3, 8},
//        {(unsigned long int *)&OBJC_IVAR_$_OcBlockTest$_age, "_age", "q", 3, 8}}
//};
//
//static struct /*_method_list_t*/ {
//    unsigned int entsize;  // sizeof(struct _objc_method)
//    unsigned int method_count;
//    struct _objc_method method_list[10];
//} _OBJC_$_INSTANCE_METHODS_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_const"))) = {
//    sizeof(_objc_method),
//    10,
//    {{(struct objc_selector *)"doBlockTest", "v16@0:8", (void *)_I_OcBlockTest_doBlockTest},
//        {(struct objc_selector *)"testStackParam", "v16@0:8", (void *)_I_OcBlockTest_testStackParam},
//        {(struct objc_selector *)"name", "@16@0:8", (void *)_I_OcBlockTest_name},
//        {(struct objc_selector *)"setName:", "v24@0:8@16", (void *)_I_OcBlockTest_setName_},
//        {(struct objc_selector *)"finishedBlock", "@?16@0:8", (void *)_I_OcBlockTest_finishedBlock},
//        {(struct objc_selector *)"setFinishedBlock:", "v24@0:8@?16", (void *)_I_OcBlockTest_setFinishedBlock_},
//        {(struct objc_selector *)"fatherName", "@16@0:8", (void *)_I_OcBlockTest_fatherName},
//        {(struct objc_selector *)"setFatherName:", "v24@0:8@16", (void *)_I_OcBlockTest_setFatherName_},
//        {(struct objc_selector *)"age", "q16@0:8", (void *)_I_OcBlockTest_age},
//        {(struct objc_selector *)"setAge:", "v24@0:8q16", (void *)_I_OcBlockTest_setAge_}}
//};
//
//static struct /*_method_list_t*/ {
//    unsigned int entsize;  // sizeof(struct _objc_method)
//    unsigned int method_count;
//    struct _objc_method method_list[1];
//} _OBJC_$_CLASS_METHODS_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_const"))) = {
//    sizeof(_objc_method),
//    1,
//    {{(struct objc_selector *)"startTest", "v16@0:8", (void *)_C_OcBlockTest_startTest}}
//};
//
//static struct _class_ro_t _OBJC_METACLASS_RO_$_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_const"))) = {
//    1, sizeof(struct _class_t), sizeof(struct _class_t),
//    (unsigned int)0,
//    0,
//    "OcBlockTest",
//    (const struct _method_list_t *)&_OBJC_$_CLASS_METHODS_OcBlockTest,
//    0,
//    0,
//    0,
//    0,
//};
//
//static struct _class_ro_t _OBJC_CLASS_RO_$_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_const"))) = {
//    0, __OFFSETOFIVAR__(struct OcBlockTest, _name), sizeof(struct OcBlockTest_IMPL),
//    (unsigned int)0,
//    0,
//    "OcBlockTest",
//    (const struct _method_list_t *)&_OBJC_$_INSTANCE_METHODS_OcBlockTest,
//    0,
//    (const struct _ivar_list_t *)&_OBJC_$_INSTANCE_VARIABLES_OcBlockTest,
//    0,
//    0,
//};
//
//extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_WxObjectTestBase;
//extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;
//
//extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_data"))) = {
//    0, // &OBJC_METACLASS_$_NSObject,
//    0, // &OBJC_METACLASS_$_WxObjectTestBase,
//    0, // (void *)&_objc_empty_cache,
//    0, // unused, was (void *)&_objc_empty_vtable,
//    &_OBJC_METACLASS_RO_$_OcBlockTest,
//};
//
//extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_WxObjectTestBase;
//
//extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_OcBlockTest __attribute__ ((used, section ("__DATA,__objc_data"))) = {
//    0, // &OBJC_METACLASS_$_OcBlockTest,
//    0, // &OBJC_CLASS_$_WxObjectTestBase,
//    0, // (void *)&_objc_empty_cache,
//    0, // unused, was (void *)&_objc_empty_vtable,
//    &_OBJC_CLASS_RO_$_OcBlockTest,
//};
//static void OBJC_CLASS_SETUP_$_OcBlockTest(void ) {
//    OBJC_METACLASS_$_OcBlockTest.isa = &OBJC_METACLASS_$_NSObject;
//    OBJC_METACLASS_$_OcBlockTest.superclass = &OBJC_METACLASS_$_WxObjectTestBase;
//    OBJC_METACLASS_$_OcBlockTest.cache = &_objc_empty_cache;
//    OBJC_CLASS_$_OcBlockTest.isa = &OBJC_METACLASS_$_OcBlockTest;
//    OBJC_CLASS_$_OcBlockTest.superclass = &OBJC_CLASS_$_WxObjectTestBase;
//    OBJC_CLASS_$_OcBlockTest.cache = &_objc_empty_cache;
//}
//#pragma section(".objc_inithooks$B", long, read, write)
//__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CLASS_SETUP[] = {
//    (void *)&OBJC_CLASS_SETUP_$_OcBlockTest,
//};
//static struct _class_t *L_OBJC_LABEL_CLASS_$ [1] __attribute__((used, section ("__DATA, __objc_classlist,regular,no_dead_strip")))= {
//    &OBJC_CLASS_$_OcBlockTest,
//};
//static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
//
