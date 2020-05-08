//
//  BaseGrammarTest.m
//  testcode
//
//  Created by wqan3313 on 2018/5/18.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import "BaseGrammarTest.h"
#import "NSArray+Safe.h"

@implementation BaseGrammarTest
static BaseGrammarTest *instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:nil] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return self;
}

- (void)startTask {
    id nilObj = nil;
    id nilKey = nil;
    NSString *countStr = nil;
    NSInteger a = [countStr integerValue];  //0
    NSString *countStrB = @"sasa";
    NSInteger b = [countStrB integerValue];  //0
    NSNumber *floatV = @5.6;
    NSInteger c = floatV.integerValue;     //向下取整
    NSLog(@"number is a:%zd b:%zd c%zd", a, b, c);
    
    id nilArr = @[@1, nilObj]; //__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object from objects[1]'
    id arr = [NSArray arrayWithObjects:@1, @5, @7, @11, nil]; //
    NSArray *arrn = [[NSArray alloc] init];
    NSArray *arrnnull = nil;
    id arr2 = [NSMutableArray arrayWithObjects:@1, nil];
    NSMutableArray *marrn = [NSMutableArray arrayWithArray:arr];
    NSLog(@"NSArray: %@ %@ %@ %@", [NSArray class], [arr class], [arrn class], [arrnnull class]);
    NSLog(@"NSMutableArray: %@ %@ %@", [NSMutableArray class], [arr2 class], [marrn class]);
    //    2018-05-31 09:43:24.706245+0800 testcode[4196:40707] NSArray: NSArray __NSArrayI __NSArray0 (null)
    //    2018-05-31 09:43:24.706439+0800 testcode[4196:40707] NSMutableArray: NSMutableArray __NSArrayM __NSArrayM
    
    //safe arrary
    [arr safe_objectAtIndexI:10];
    [arrn safe_objectAtIndexI:10];
    [arrnnull safe_objectAtIndexI:10];
    [marrn objectAtIndex:10];
    [marrn insertObject:@3 atIndex:10];
    [marrn removeObjectAtIndex:13];
    [marrn addObject:@3];
    [marrn removeObject:@5];
    [marrn replaceObjectAtIndex:0 withObject:@111];
    

    id dict = @{@"1" : @"a", @"2" : @"b", @"C":nilObj}; //__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[2]'
    dict = @{@"1" : @"a", @"2" : @"b", nilKey:@3}; //__NSPlaceholderDictionary initWithObjects:forKeys:count:]: attempt to insert nil object from objects[2]'
    id dict1 = [NSDictionary dictionaryWithObject:@"a" forKey:@"1"];
    NSDictionary *dictn = [[NSDictionary alloc] init];
    id mdict = [NSMutableDictionary dictionaryWithObject:@"a" forKey:@"1"];
    NSMutableDictionary *mdictn = [[NSMutableDictionary alloc] init];
    NSLog(@"NSDictionary: %@ %@ %@ %@", [NSDictionary class], [dict class], [dict1 class], [dictn class]);
    NSLog(@"NSMutableDictionary: %@ %@ %@", [NSMutableDictionary class], [mdict class], [mdictn class]);
    
    [mdict setObject:nil forKey:nil];
    if ([arr isKindOfClass:[NSArray class]] && [arrn isKindOfClass:[NSArray class]]) {
        NSLog(@"1([arr isKindOfClass:[NSArray class]] && [arrn isKindOfClass:[NSArray class]])");
    }
    if ([arr2 isKindOfClass:[NSArray class]] && [marrn isKindOfClass:[NSArray class]]) {
        NSLog(@"2([arr2 isKindOfClass:[NSArray class]] && [marrn isKindOfClass:[NSArray class]])");
    }
    if ([arr2 isKindOfClass:[NSMutableArray class]] && [marrn isKindOfClass:[NSMutableArray class]]) {
        NSLog(@"3([arr2 isKindOfClass:[NSMutableArray class]] && [marrn isKindOfClass:[NSMutableArray class]])");
    }
    if ([arr2 isMemberOfClass:NSClassFromString(@"__NSArrayM")]) {
        NSLog(@"4([arr2 isMemberOfClass:[NSMutableArray class]] && [marrn isMemberOfClass:[NSMutableArray class]])");
    }
//    2018-05-31 09:43:24.705438+0800 testcode[4196:40707] number is a:0 b:0 c5
//    2018-05-31 09:43:24.707146+0800 testcode[4196:40707] NSDictionary: NSDictionary __NSDictionaryI __NSSingleEntryDictionaryI __NSDictionary0
//    2018-05-31 09:43:24.707283+0800 testcode[4196:40707] NSMutableDictionary: NSMutableDictionary __NSDictionaryM __NSDictionaryM
}

+ (NSInteger)Factorial:(NSInteger)n {
    if (n == 1) {
        return 1;
    }
    return n * [BaseGrammarTest Factorial:n-1];
}

+ (NSInteger)TailFactorial:(NSInteger)n sum:(NSInteger)sum {
    if (n == 1) {
        return sum;
    }
    return [BaseGrammarTest TailFactorial:n-1 sum:n * sum];
}
@end
