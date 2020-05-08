//
//  WxRedBlackTree+CommonOpt.m
//  debug-objc
//
//  Created by wqa on 2018/11/17.
//

#import "WxBinarySearchTree.h"
#import "WxStack.h"


@implementation TreeNode
@dynamic color;
@dynamic height;

- (instancetype)init {
    if (self = [super init]) {
        self.banlanceData = new BalanceData();
    }
    return self;
}

- (void)dealloc {
    if (self.banlanceData) {
        delete self.banlanceData; //new 的对象需要delete
    }
}

- (instancetype)initWithDataColor:(NSNumber *)d color:(TreeNodeColor)color{
    if (self = [super init]) {
        self.data = d;
        self.banlanceData = new BalanceData();
        self.color = color;
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@" (%@ %@ %@) ", self.data, self.color==0 ? @"b" : @"r", self.parent.data];
}

- (TreeNodeColor)color {
    return self.banlanceData->color;
}

- (void)setColor:(TreeNodeColor)color {
    self.banlanceData->color = color;
}

- (void)setHeight:(NSInteger)height {
    self.banlanceData->height = height;
}

- (NSInteger)height {
    return self.banlanceData->height;
}

- (void)setLeft:(TreeNode *)left {
    _left = left;
    left.parent = self;
}

-(void)setRight:(TreeNode *)right {
    _right = right;
    right.parent = self;
}
@end


@implementation WxBinarySearchTree

- (instancetype)initWithRoot:(TreeNode *)root {
    if (self = [super init]) {
        self.root = root;
    }
    return self;
}

- (void)setRoot:(TreeNode *)root {
    _root = root;
    root.parent = nil;
}

#pragma mark - findopt
- (TreeNode *)findData:(NSNumber *)data {
    TreeNode *cur = self.root;
    while (cur != nil) {
        if (cur.data.doubleValue == data.doubleValue) {
            break;
        }
        else if (cur.data.doubleValue > data.doubleValue) {
            cur = cur.left;
        }
        else {
            cur = cur.right;
        }
    }
    return cur;
}

- (TreeNode *)getMin {
    TreeNode *cur = self.root;
    while (cur.left != nil) {
        cur = cur.left;
    }
    return cur;
}

-(TreeNode *)getMax {
    TreeNode *cur = self.root;
    while (cur.right != nil) {
        cur = cur.right;
    }
    return cur;
}

#pragma mark search
//中序遍历寻找后继节点
- (TreeNode *)findSuccessor:(TreeNode *)node {
    TreeNode *cur = nil;
    if (node.right) {
        cur = node.right;
        while (cur.left) {
            cur = cur.left;
        }
    }
    else {
        cur = node.parent;
        while (cur && node == cur.right) {
            node = cur;
            cur = node.parent;
        }
    }
    return cur;
}

//找到所有祖先  可以通过后续遍历 打印栈中元素，或者parent指针
+ (BOOL)findAllAncestors:(TreeNode *)root target:(TreeNode *)target {
    if (root == nil) {
        return NO;
    }
    if (root == target) {
        return YES;
    }
    if ([self findAllAncestors:root.left target:target] || [self findAllAncestors:root.right target:target]) {
        NSLog(@"%@", root);
        return YES;
    }
    return NO;
    
}

+ (NSArray *)findNodePath:(TreeNode *)root p:(TreeNode *)p {
    if (!root || !p) {
        return nil;
    }
    WxStack<TreeNode *> *stack = [WxStack new];
    NSMutableString *result = [NSMutableString new];
    [stack push:root];
    TreeNode *node = stack.top;
    NSInteger height = 0;
    
    while (!stack.empty) {
        while (stack.top.left) {
            [stack push:stack.top.left];
        }
        while (!stack.empty) {
            if (stack.top.right && stack.top.right != node) {
                [stack push:stack.top.right];
                break;
            }
            height = MAX(height, [stack size]);
            node = [stack pop];
            [result appendFormat:@" %@ ", node.debugDescription];
            if (node == p) {
                return [stack curStackToArry];
            }
            
        }
    }
    return nil;
}

//寻找最低公共祖先节点
+ (TreeNode *)findLCA:(TreeNode *)tree p:(TreeNode *)p q:(TreeNode *)q {
    //1.s如果是二叉查找树 从根节点比较如果值都比root大，则lca在右子树，都比root小在左子树，一个a大一个i小则当前root为lca
    //2.如果有parent指针，则可以将x.parent直到根节点的路径当前一个链表，从而转化成两个链表相交的问题
    //3.如果是普通的树 先通过后续遍历找到root到x，y的路径，转成链表相交问题
    //递归处理
    typedef TreeNode*(^findLCABlock)(TreeNode *root, TreeNode *x, TreeNode *y);
    __block findLCABlock BSTreeFind = ^TreeNode*(TreeNode *root, TreeNode *x, TreeNode *y){
        if (!root) {
            return root;
        }
        if (root.data > x.data && root.data > y.data) {
            return BSTreeFind(root.left, x, y);
        }
        else if (root.data < x.data && root.data < y.data) {
            return BSTreeFind(root.right, x, y);
        }
        return root;
    };
    
    __block findLCABlock ParentTreeFind = ^TreeNode*(TreeNode *root, TreeNode *x, TreeNode *y){
        NSMutableArray *pathX = [NSMutableArray new];
        NSMutableArray *pathY = [NSMutableArray new];
        TreeNode *pa = x.parent;
        while (pa) {
            [pathX insertObject:pa atIndex:0];
            pa = pa.parent;
        }
        pa = y.parent;
        while (pa) {
            [pathY insertObject:pa atIndex:0];
            pa = pa.parent;
        }
        //从根向下对比路径，最后一个相同的节点为公共子节点。
        int idx = 0;
        for (; idx < pathX.count && idx < pathY.count; ++idx) {
            if (pathX[idx] != pathY[idx]) {
                return pathX[idx-1];
            }
        }
        //说明x是y的父节点
        if (idx == pathX.count) {
            return x;
        }
        return y;
    };
    __weak typeof(self) weakSelf = self;
    __block findLCABlock CommonTreeFind = ^TreeNode*(TreeNode *root, TreeNode *x, TreeNode *y){
        NSArray *pathX = [weakSelf findNodePath:root p:x];
        NSArray *pathY = [weakSelf findNodePath:root p:y];
        //从根向下对比路径，最后一个相同的节点为公共子节点。
        int idx = 0;
        for (; idx < pathX.count && idx < pathY.count; ++idx) {
            if (pathX[idx] != pathY[idx]) {
                return pathX[idx-1];
            }
        }
        //说明x是y的父节点
        if (idx == pathX.count) {
            return x;
        }
        return y;
    };
    
    TreeNode *LCABSTreeFind = BSTreeFind(tree, p, q);
    TreeNode *LCAParentTreeFind = ParentTreeFind(tree, p, q);
    TreeNode *LCAcommonTreeFind = CommonTreeFind(tree, p, q);
    NSAssert(LCABSTreeFind == LCAParentTreeFind && LCAParentTreeFind == LCAcommonTreeFind, @"LCAcommonTreeFind not the same!");
    NSLog(@"node:%@ node:%@ lowest common ancestor is %@", p.debugDescription, q.debugDescription, LCAcommonTreeFind.debugDescription);
    return LCABSTreeFind;
}

+ (NSInteger)distanceNode:(TreeNode *)tree p:(TreeNode *)p q:(TreeNode *)q {
    TreeNode *LCA = [self findLCA:tree p:p q:q];
    typedef  NSInteger(^distanceToParent)(TreeNode *p, TreeNode *q);
    __block distanceToParent getParentDistance = ^NSInteger(TreeNode *x, TreeNode *y){
        if (x == nil || y == nil) {
            return -1;
        }
        if (x == y) {
            return 0;
        }
        NSInteger level = getParentDistance(x.left, y);
        if (level == -1) {
            level = getParentDistance(x.right, y);
        }
        if (level != -1) {
            return level + 1;
        }
        return -1;
    };
    NSInteger distance = getParentDistance(LCA, p) + getParentDistance(LCA, q);
    NSLog(@"distanceNode between %@ %@ is %ld", p.debugDescription, q.debugDescription, distance);
    return distance;
}

//检查是否完全二叉树
+ (BOOL)checkIsCBT:(TreeNode *)root {
    NSMutableArray<TreeNode *> *queue = [NSMutableArray new];
    [queue insertObject:root atIndex:0];
    
    BOOL findLeafNode = NO;
    while (queue.count != 0) {
        TreeNode *node = ({
            TreeNode *last = queue.lastObject;
            [queue removeLastObject];
            last;
        });
        if (findLeafNode && (node.left || node.right)) {
            return NO;
        }
        if (node.left && node.right) {
            [queue insertObject:node.left atIndex:0];
            [queue insertObject:node.right atIndex:0];
        }
        else if (node.right) {
            return NO;
        }
        else if (node.left) {
            findLeafNode = YES;
            [queue insertObject:node.left atIndex:0];
        }
        else {
            findLeafNode = YES;
        }
    }
    return YES;
}

#pragma mark visit-tree
+ (void)preTravel:(TreeNode *)root {
    if (!root) {
        return;
    }
    WxStack<TreeNode *> *stack = [WxStack new];
    NSMutableString *result = [NSMutableString new];
    [stack push:root];
    
    while (!stack.empty) {
        TreeNode *node = [stack pop];
        [result appendFormat:@" %@ ", node.debugDescription];
        if (node.right) {
            [stack push:node.right];
        }
        if (node.left) {
            [stack push:node.left];
        }
        else {
            [result appendString:@" \n "];
        }
    }
    NSLog(@"%@", result);
}

+ (void)inOrderTravel:(TreeNode *)root {
    if (!root) {
        return;
    }
    WxStack<TreeNode *> *stack = [WxStack new];
    NSMutableString *result = [NSMutableString new];
    [stack push:root];
    TreeNode *node = stack.top;
    
    while (!stack.empty) {
        while (stack.top.left) {
            [stack push:stack.top.left];
        }
        while (!stack.empty) {
            node = [stack pop];
            [result appendFormat:@" %@ ", node.data];
            if (node.right) {
                [stack push:node.right];
                break;
            }
        }
    }
    NSLog(@"%@", result);
}

+ (NSInteger)postTravel_height:(TreeNode *)root {
    if (!root) {
        return 0;
    }
    WxStack<TreeNode *> *stack = [WxStack new];
    NSMutableString *result = [NSMutableString new];
    [stack push:root];
    TreeNode *node = stack.top;
    NSInteger height = 0;
    
    while (!stack.empty) {
        while (stack.top.left) {
            [stack push:stack.top.left];
        }
        while (!stack.empty) {
            if (stack.top.right && stack.top.right != node) {
                [stack push:stack.top.right];
                break;
            }
            height = MAX(height, [stack size]);
            node = [stack pop];
            [result appendFormat:@" %@ ", node.debugDescription];
        }
    }
    NSLog(@"%@ height%ld", result, height);
    return height;
}

+ (NSInteger)levelTreavel_height:(TreeNode *)tree {
    NSMutableArray *queue = [NSMutableArray new];
    NSMutableString *result = [NSMutableString new];
    NSInteger height = 0;
    [queue addObject:tree];
    TreeNode *node;
    
    while (queue.count > 0) {
        NSMutableArray *nextLevel = [NSMutableArray new];
        while (queue.count > 0) {
            node = queue.lastObject;
            [queue removeLastObject];
            [result appendFormat:@" %@ ", node.debugDescription];
            if (node.left) {
                [nextLevel insertObject:node.left atIndex:0];
            }
            if (node.right) {
                [nextLevel insertObject:node.right atIndex:0];
            }
        }
        [result appendString:@"\n"];
        height = height + 1;
        [queue addObjectsFromArray:nextLevel];
        
    }
    NSLog(@"%@ height:%ld", result, height);
    return height;
}

+ (NSInteger)recursive_heght:(TreeNode *)tree {
    if (!tree) {
        return 0;
    }
    NSInteger leftH = [self recursive_heght:tree.left];
    NSInteger rightH = [self recursive_heght:tree.right];
    return MAX(leftH+1, rightH+1);
}

- (TreeNode *)leftRotate:(TreeNode *)curNode {
    TreeNode *parent = curNode.parent;
    TreeNode *rightS = curNode.right;
    TreeNode *RL = rightS.left;
    
    rightS.parent = parent;
    if (parent == nil) {
        self.root = rightS;
    }
    else if (curNode == parent.left) {
        parent.left = rightS;
    }
    else {
        parent.right = rightS;
    }
    curNode.parent = rightS; rightS.left = curNode;
    curNode.right = RL, RL.parent = curNode;
    return rightS;
}

#pragma mark insert-delete
- (TreeNode *)rightRotate:(TreeNode *)curNode {
    TreeNode *parent = curNode.parent;
    TreeNode *leftS = curNode.left;
    TreeNode *LR = leftS.right;
    
    //父节点左右儿子改变
    leftS.parent = parent;
    if (parent == nil) {
        self.root = leftS;
    } else if (parent.left == curNode) {
        parent.left = leftS;
    } else {
        parent.right = leftS;
    }
    //当前节点二叉树 变成左儿子右子树
    curNode.parent = leftS; leftS.right = curNode;
    //左儿子右子树 变成当前节点左子树
    curNode.left = LR; LR.parent = curNode;
    return leftS;
}
@end
