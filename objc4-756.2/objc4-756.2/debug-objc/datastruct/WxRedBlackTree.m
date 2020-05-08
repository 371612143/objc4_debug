//
//  WxBinaryTree.m
//  debug-objc
//
//  Created by wqa on 2018/11/10.
//

#import "WxRedBlackTree.h"
#import "WxStack.h"
#import <objc/runtime.h>


@implementation WxRedBlackTree

+ (void)startTest {
    //srand([[NSDate date] timeIntervalSince1970]);
    WxRedBlackTree *tree = [WxRedBlackTree new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (int idx = 0; idx < 100; ++idx) {
        NSNumber *num = [NSNumber numberWithInteger:random()%100];
        if (![dict objectForKey:num]) {
            [tree insertData:num];
            [dict setObject:num forKey:num];
            [self check_RBTree:tree.root];
        }
        
    }
    [WxRedBlackTree inOrderTravel:tree.root];
    NSLog(@"data:inOrderTravel");
    [WxRedBlackTree levelTreavel_height:tree.root];
    NSLog(@"data:levelTreavel");
    
    int left = dict.count;
    for (id key in dict.allKeys) {
        [tree deleteData:dict[key]];
        [self check_RBTree:tree.root];
        if (--left <= 20) {
            break;
        }
    }
    [WxRedBlackTree distanceNode:tree.root p:[tree findData:[NSNumber numberWithInteger:68]] q:[tree findData:[NSNumber numberWithInteger:76]]];
    [WxRedBlackTree inOrderTravel:tree.root];
    NSLog(@"data:inOrderTravel");
    [WxRedBlackTree levelTreavel_height:tree.root];
    NSLog(@"data:levelTreavel");
    //    [WxRedBlackTree preTravel:tree.root];
    //    NSLog(@"data:firtTravel");
    //    [WxRedBlackTree inOrderTravel:tree.root];
    //    NSLog(@"data:inOrderTravel");
    //    [WxRedBlackTree postTravel_height:tree.root];
    //    NSLog(@"data:lastTravel");
    //    [WxRedBlackTree levelTreavel_height:tree.root];
    //    NSLog(@"data:levelTreavel");
    //    NSInteger heigt = [WxRedBlackTree recursive_heght:tree.root];
    //    NSLog(@"data:recursive_heght:%ld", heigt);
}

- (void)insertData:(NSNumber *)data {
    
    TreeNode *pre = nil, *cur = self.root;
    while (cur != nil) {
        pre = cur;
        if (cur.data > data) {
            cur = cur.left;
        } else {
            cur = cur.right;
        }
    }
    TreeNode *newNode = [[TreeNode alloc] initWithDataColor:data color:red];
    if (pre == nil) {
        self.root = newNode;
    } else if (pre.data >= newNode.data) {
        pre.left = newNode;
    } else {
        pre.right = newNode;
    }
    newNode.parent = pre;
    [self insertFixUp:newNode];
}

- (void)insertFixUp:(TreeNode *)curNode {
    TreeNode *parent = curNode.parent, *uncle = nil;
    //父节点为黑色 或者空直接插入
    while (curNode != self.root && parent.color == red) {
        if (parent.parent != nil) { //没有祖父节点 父节点是根节点 直接把根节点染黑
            //父节点是左子树
            if (parent == parent.parent.left) {
                uncle = parent.parent.right;
                //case 1 父亲，叔叔节点是红色 执行颜色翻转，父叔变黑-gp涂红，将祖父节点改为待平衡的红节点，上滤，曾祖节点黑结束，红继续
                if (uncle && uncle.color == red) {
                    uncle.color = parent.color = black;
                    parent.parent.color = red;
                    curNode = parent.parent;
                    parent = curNode.parent;
                }
                else {
                    //case 2 叔叔节点是黑，待插入点是右子树，Cr-Pr-Gb <形排列，需要左旋父节点，转换为 case3一字型排列，需要双旋转
                    if (curNode == parent.right) {
                        [self leftRotate:parent];
                        curNode = curNode.left;
                        parent = curNode.parent;
                    }
                    //父节点涂黑 祖父涂红 右旋，将之前祖父节点的右子树改为待插入节点, Cr-Pr-Gb 为一字型，转为Cr-Pb-Gr再右旋(满足条件4） Pb变为根节点，Cr，Gb成为左右子树黑色节点平衡(满足条件5）
                    //此时条件
                    parent.color = black;
                    parent.parent.color = red;
                    [self rightRotate:parent.parent];
                    break;
                }
            }
            else {
                //父节点为右子树 操作与之前相反
                uncle = parent.parent.left;
                if (uncle && uncle.color == red) {
                    uncle.color = parent.color = black;
                    parent.parent.color = red;
                    curNode = parent.parent;
                    parent = curNode.parent;
                }
                else {
                    if (curNode == parent.left) {
                        [self rightRotate:parent];
                        curNode = curNode.right;
                        parent = curNode.parent;
                    }
                    parent.color = black;
                    parent.parent.color = red;
                    [self leftRotate:parent.parent];
                    break;
                }
            }

        }
        else {
            break;
        }

    }
    self.root.color = black;

}

- (void)deleteFixUp:(TreeNode *)node parent:(TreeNode *)parent{
    TreeNode *brother = nil;
    //删除黑节点后树的平衡被破坏，所以被删除黑节点视为黑色权值*2 将黑+黑节点中多余的黑节点上移，直到找到红节点
    while (node.color == black && node != self.root) {
        if (parent.left == node) {
            brother = parent.right;
            //CASE 1 兄弟节点是红色 兄弟节点改黑父节点变红 左旋(b=red,b.left=black,之前兄弟节点的左子树变成新的兄弟节点，新的兄弟节点肯定为黑) 变成case2，3，4
            if (brother.color == red) {
                brother.color = black; parent.color = red;  //保证左旋后性质5
                [self leftRotate:parent];
                brother = parent.right;
            }
            //case 2 兄弟节点是黑，兄弟左右i子树是黑，兄弟节点置红，黑节点上移，需要找到兄弟节点有一个红孩子，并把哄孩子涂黑，左旋后树会达到平衡
            if (brother.left.color == black && brother.right.color == black) {
                brother.color = red;
                node = parent;
                parent = node.parent;
            }
            else {
                //兄弟右子树为黑，左孩子红，左孩子置黑，兄弟置红右旋兄弟节点 变成case 4
                if (brother.right.color == black) {
                    brother.left.color = black;
                    brother.color = red;
                    [self rightRotate:brother];
                    brother = parent.right;
                }
                //兄弟左子树黑 右子树红
                brother.color = parent.color; //因为左旋后兄弟节点变成父节点 所以兄弟节点颜色要变成父节点一致
                parent.color = black;         //左旋后替代删除黑色节点，确保替代节点是黑色
                brother.right.color = black; //红置黑，保持左旋后右子树黑色平衡
                [self leftRotate:parent]; //左旋后平衡
                node = self.root;  //处理根节点
            }
        }
        else {
            //情况与上面相反
            brother = parent.left;
            if (brother.color == red) {
                brother.color = black;
                parent.color = red;
                [self rightRotate:parent];
                brother = parent.left;
            }
            if (brother.left.color == black && brother.right.color == black) {
                brother.color = red;
                node = parent;
                parent = node.parent;
            }
            else {
                if (brother.left.color == black) {
                    brother.right.color = black;
                    brother.color = red;
                    [self leftRotate:brother];
                    brother = parent.left;
                }
                brother.color = parent.color;
                parent.color = black;
                brother.left.color = black;
                [self rightRotate:parent];
                node = self.root;
            }
        }
    }
    node.color = black;
}

- (BOOL)deleteData:(NSNumber *)data {
    //寻找要删除的数据元素
    TreeNode *cur = [self findData:data];
    if (cur == nil) {
        return NO;
    }
    //寻找删除节点
    TreeNode *delNode = cur, *parent = cur.parent, *child;
    if (cur.left != nil && cur.right != nil){
        //左右子树都不为空 改为删除右子树最小节点
        delNode = cur.right;
        while (delNode.left) {
            delNode = delNode.left;
        }
        cur.data = delNode.data;
        parent = delNode.parent;
    }
    
    //二叉查找树删除节点
    //找到不为空的子树 并把他赋值给删除点对应的左右子树分支 父节点为空则把子树当成根节点
    TreeNodeColor delColor = delNode.color;
    child = delNode.left ? delNode.left : delNode.right;
    if (parent == nil) {
        self.root = child;
    }
    else if (parent.left == delNode) {
        parent.left = child;
    } else {
        parent.right = child;
    }
    child.parent = parent;

    //动态更新 删除是红节点 没关系
    if (delColor == black) {
        [self deleteFixUp:child parent:parent];
    }

    
    return YES;
}

//红黑树自省
+ (NSInteger)check_RBTree:(TreeNode *)tree {
    if (!tree) {
        return 0;
    }
    Class sup = [self superclass];
    Class cls = [self class];
    Class meta = object_getClass(self);
    __weak typeof(self) weakSelf = self;
    void(^printBlock)(TreeNode* node, NSString *reason) = ^(TreeNode *node, NSString *reason) {
        TreeNode *root = node;
        while (root.parent) {
            root = root.parent;
        }
        [weakSelf levelTreavel_height:root];
        NSString *res = [NSString stringWithFormat:@"rb_tree condition error! %@", reason];
        NSAssert(0, res);

    };
    NSInteger leftH = [self check_RBTree:tree.left];
    NSInteger rightH = [self check_RBTree:tree.right];
    if (leftH != rightH) {
        printBlock(tree, @"height");
    }
    if ((tree.left && tree.data < tree.left.data) || (tree.right && tree.data > tree.right.data)) {
        printBlock(tree, @"value");
    }
    if ((tree.color == red) && (tree.left.color == red || tree.right.color == red)) {
        printBlock(tree, @"color");
    }

    NSInteger curLevelH = tree.color == black ? 1 : 0;
    return MAX(leftH+curLevelH, rightH+curLevelH);
}

@end
