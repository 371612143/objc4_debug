//
//  Person.h
//  testcode
//
//  Created by wqan3313 on 2018/5/15.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface Parent : NSObject
@property (nonatomic, assign)char ap;
@property (nonatomic, weak)NSNumber *pNumber;
@property (nonatomic, assign)char bp;
@end

@interface Person : Parent


//_a offset:24
//_b offset:25
//_sex offset:28
//_age offset:32
//_wNumbera offset:40
//_weight offset:48
//_money offset:56
//_name offset:64
//_wNumberb offset:72
//OC会对内存做一些计算 成员变量的内存排序顺序是按照声明顺序来的,跟c++一样改变变量的声明顺序会影响内存存储的大小。而property的变量会在编译时做自动字节对齐和生成getter和setter，使对象的内存占用在不影响字节对齐的情况下重排达到最小值。所以如果在分类中声明属性会破坏对象的内存字节对齐和变量的内存布局。在kvo中通过object_setClass()改变了对象的setter和getter以及一些容易的设值方法，但是在[obj class]方法必须返回原有的类，不然会导致用户使用时发生未知错误。父类中的实例变量布局在会在子类前面

@property (nonatomic, assign)char a;
@property (nonatomic, weak)NSNumber *wNumbera;
@property (nonatomic, assign)double weight;
@property (nonatomic, assign)char b;
@property (nonatomic, assign)double money;  //SIZE = 40
@property (nonatomic, assign)int sex;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, weak)NSNumber *wNumberb;
@property (nonatomic, assign)int age;


- (NSInteger)gotoSchool;
- (void)haveEnglishClass;
- (void)playComputerGame;
+ (void)canEatRice;
- (void)walk;
@end
