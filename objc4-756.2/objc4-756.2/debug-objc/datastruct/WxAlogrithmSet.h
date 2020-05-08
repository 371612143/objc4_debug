//
//  WxAlogrithmSet.h
//  debug-objc
//
//  Created by wqa on 2018/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray<NSNumber *> SortDataArr;

@interface WxAlogrithmSet : NSObject

+ (void)startTest;

+ (void)insertSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high;
+ (void)bubbleSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high;
+ (void)mergerSort:(SortDataArr *)arr low:(NSInteger)low high:(NSInteger)high tmpArr:(SortDataArr *)tmpArr;

+ (void)selectSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high;
+ (void)quickSort:(NSMutableArray<NSNumber *> *)arr low:(NSInteger)low high:(NSInteger)high;
+ (void)heapSort:(SortDataArr *) arr;
@end

NS_ASSUME_NONNULL_END
