//
//  WxBinaryTree.h
//  debug-objc
//
//  Created by wqa on 2018/11/10.
//

#import <Foundation/Foundation.h>
#import "WxBinarySearchTree.h"
/*
 红黑树，RBTREE, RB-TREE
 满足以下性质的二叉查找树
（1）每个节点或者是黑色，或者是红色。
（2）根节点是黑色。
（3）每个叶子节点（NIL）是黑色。 [注意：这里叶子节点，是指为空(NIL或NULL)的叶子节点！]
（4）如果一个节点是红色的，则它的子节点必须是黑色的。
（5）从一个节点到该节点的子孙节点的所有路径上包含相同数目的黑节点。
 节点有红黑2色，根叶子为黑。(5)，（4）
 */



@interface WxRedBlackTree : WxBinarySearchTree
+ (void)startTest;
//自平衡插入元素
- (void)insertData:(NSNumber *)data;
//删除元素自平衡
- (BOOL)deleteData:(NSNumber *)data;
//检查是否红黑色 1.黑色高度相等，2.不能有两个相连红节点 3.满足2叉查找树
+ (NSInteger)check_RBTree:(TreeNode *)tree;
@end

