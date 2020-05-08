//
//  WxRedBlackTree+CommonOpt.h
//  debug-objc
//
//  Created by wqa on 2018/11/17.
//

#import <Foundation/Foundation.h>

@class TreeNode;
typedef NS_ENUM(NSInteger, TreeNodeColor){
    black = 0,
    red = 1
};

union BalanceData {
    TreeNodeColor color;
    NSInteger height;
};


#define leafNode  nil
#define leftSon(node) node.left
#define righSon(node) node.right

//data:levelTreavel
//_data offset:8
//_banlanceData offset:16
//_left offset:24
//_right offset:32
//_parent offset:40
//TreeNode class_getInstanceSize:48, 48
//height = 0;
//color = 0;
//parent = (null);
//right = (null);
//left = (null);
//[<TreeNode 0x100e1e7a0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key banlanceData.

//@dynamic 不会自动生成，setter，getter和对应ivar 2.union不支持kvc
@interface TreeNode : NSObject
@property(nonatomic, strong)NSNumber *data;
@property(nonatomic, assign)union BalanceData *banlanceData;
@property(nonatomic, strong)TreeNode *left;
@property(nonatomic, strong)TreeNode *right;
@property(nonatomic, strong)TreeNode *parent;
@property(nonatomic, assign) TreeNodeColor color;
@property(nonatomic, assign) NSInteger height;

- (instancetype)initWithDataColor:(NSNumber *)d color:(TreeNodeColor)color;
@end

//二叉树常规操作
@interface WxBinarySearchTree :  NSObject
@property(nonatomic, strong)TreeNode *root;
- (instancetype)initWithRoot:(TreeNode *)root;

- (TreeNode *)findData:(NSNumber *)data;
//最大元素 右子树最右
- (TreeNode *)getMax;
//最小元素 左子树最左
- (TreeNode *)getMin;
//寻找后继节点
- (TreeNode *)findSuccessor:(TreeNode *)node;
//找到所有祖先  可以通过后续遍历 打印栈中元素，或者parent指针
+ (BOOL)findAllAncestors:(TreeNode *)root target:(TreeNode *)target;
//检查是否完全二叉树
+ (BOOL)checkIsCBT:(TreeNode *)root;
//寻找最低公共祖先节点
+ (TreeNode *)findLCA:(TreeNode *)tree p:(TreeNode *)p q:(TreeNode *)q;
//计算连个节点距离
+ (NSInteger)distanceNode:(TreeNode *)tree p:(TreeNode *)p q:(TreeNode *)q;


//A、访问根结点；B、先序遍历左子树；C、先序遍历右子树。
+ (void)preTravel:(TreeNode *)root;
//A、中序遍历左子树；B、访问根结点；C、中序遍历右子树。
+ (void)inOrderTravel:(TreeNode *)root;
//A、后序遍历左子树；B、后序遍历右子树；C、访问根结点。
+ (NSInteger)postTravel_height:(TreeNode *)root;
//A、将根结点入队B、访问队头元素指向的二叉树结点C、将队头元素出队，队头元素的孩子入队D、判断队列是否为空，如果非空，继续B；如果为空，结束。
+ (NSInteger)levelTreavel_height:(TreeNode *)tree;
+ (NSInteger)recursive_heght:(TreeNode *)tree;

//左右旋
- (TreeNode *)leftRotate:(TreeNode *)curNode;
- (TreeNode *)rightRotate:(TreeNode *)curNode;
@end

