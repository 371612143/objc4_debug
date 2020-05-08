//
//  WxAVLTree.h
//  debug-objc
//
//  Created by wqa on 2018/11/18.
//

#import <Foundation/Foundation.h>
#import "WxBinarySearchTree.h"

NS_ASSUME_NONNULL_BEGIN

@interface WxAVLTree : WxBinarySearchTree
+ (void)startTest;
//自平衡插入元素
- (void)insertData:(NSNumber *)data;
//删除元素自平衡
- (BOOL)deleteData:(NSNumber *)data;
//遍历元素逐个打印高度
- (NSInteger)AVL_LevelTravel:(TreeNode *)tree;
@end

NS_ASSUME_NONNULL_END
