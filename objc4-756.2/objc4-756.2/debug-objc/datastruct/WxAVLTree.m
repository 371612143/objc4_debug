//
//  WxAVLTree.m
//  debug-objc
//
//  Created by wqa on 2018/11/18.
//

#import "WxAVLTree.h"

@implementation WxAVLTree

+ (void)startTest {
    WxAVLTree *tree = [WxAVLTree new];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for (int idx = 0; idx < 100; ++idx) {
        NSNumber *num = [NSNumber numberWithInteger:random()%100];
        if (![dict objectForKey:num]) {
            [tree insertData:num];
            [dict setObject:num forKey:num];
        }
        
    }
    [WxAVLTree inOrderTravel:tree.root];
    NSLog(@"data:inOrderTravel");
    [tree AVL_LevelTravel:tree.root];
    NSLog(@"data:levelTreavel");
    
    int left = dict.count;
    for (id key in dict.allKeys) {
        [tree deleteData:dict[key]];
        [tree AVL_LevelTravel:tree.root];
        if (--left <= 20) {
            break;
        }
    }
    //[WxAVLTree distanceNode:tree.root p:[tree findData:[NSNumber numberWithInteger:68]] q:[tree findData:[NSNumber numberWithInteger:76]]];
    [WxAVLTree inOrderTravel:tree.root];
    NSLog(@"data:inOrderTravel");
    [tree AVL_LevelTravel:tree.root];
    NSLog(@"data:levelTreavel");
}

- (void)insertData:(NSNumber *)data {
    self.root = [self AVLInsertData:self.root data:data];
    [self check_AVLTree:self.root];
}

- (TreeNode *)AVLInsertData:(TreeNode *)tree data:(NSNumber *)data {
    if (tree == nil) {
        tree = [TreeNode new];
        tree.data = data;
        tree.banlanceData->height = 1;
        return tree;
    }
    else if (data < tree.data) {
        tree.left = [self AVLInsertData:tree.left data:data];
    }
    else {
        tree.right = [self AVLInsertData:tree.right data:data];
    }
    
    //递归 动态更新height，旋转自平衡
    if ([self getHeight:tree.left] - [self getHeight:tree.right] == 2) {
        if (data >= tree.left.data) {
            [self AVL_LeftRotate:tree.left];
        }
        tree = [self AVL_rightRotate:tree];
    }
    else if ([self getHeight:tree.left] - [self getHeight:tree.right] == -2) {
        if (data <= tree.right.data) {
            [self AVL_rightRotate:tree.right];
        }
        tree = [self AVL_LeftRotate:tree];
    }
    [self updateNodeHeight:tree];
    return tree;
}

- (BOOL)deleteData:(NSNumber *)data {
    TreeNode *node = [self AVLDeleteData:self.root data:data];
    [self check_AVLTree:self.root];
    return node != nil;
    
}

- (TreeNode *)AVLDeleteData:(TreeNode *)tree data:(NSNumber *)data {
    if (tree == nil) {
        return tree;
    }
    if (tree.data == data) {
        //AVL树 如果没有右子树，则左子树最大高度为1， 有右子树，则找到右子树上的后继节点替代删除节点
        TreeNode *delNode = tree;
        if (tree.right) {
            delNode = tree.right;
            while (delNode.left) {
                delNode = delNode.left;
            }
            tree.data = delNode.data;
            tree.right = [self AVLDeleteData:tree.right data:delNode.data];
        }
        else {
            tree = tree.left; //删除后用左子树代替
            return tree;
        }

        
    }
    else if (tree.data > data) {
        tree.left = [self AVLDeleteData:tree.left data:data];
    }
    else {
        tree.right = [self AVLDeleteData:tree.right data:data];
    }
    
    //递归 动态更新height，旋转自平衡
    if ([self getHeight:tree.left] - [self getHeight:tree.right] == 2) {
        if ([self getHeight:tree.left.left] < [self getHeight:tree.left.right]) {
            [self AVL_LeftRotate:tree.left];
        }
        tree = [self AVL_rightRotate:tree];
        
    }
    else if ([self getHeight:tree.left] - [self getHeight:tree.right] == -2) {
        if ([self getHeight:tree.right.right] < [self getHeight:tree.right.left]) {
            [self AVL_rightRotate:tree.right];
        }
        tree = [self AVL_LeftRotate:tree];
    }
    [self updateNodeHeight:tree];
    return tree;
}

- (NSInteger)updateNodeHeight:(TreeNode *)node {
    node.height = MAX([self getHeight:node.left], [self getHeight:node.right]) + 1;
    return node.height;
}

- (NSInteger)getHeight:(TreeNode *)node {
    if (!node) {
        return 0;
    }
    return node.height;
}

- (TreeNode *)AVL_LeftRotate:(TreeNode *)node {
    TreeNode *rightS = node.right;
    [super leftRotate:node];
    [self updateNodeHeight:node];
    [self updateNodeHeight:rightS];
    return rightS;
}

- (TreeNode *)AVL_rightRotate:(TreeNode *)node {
    TreeNode *leftS = node.left;
    [super rightRotate:node];
    [self updateNodeHeight:node];
    [self updateNodeHeight:leftS];
    return leftS;
}

- (NSInteger)AVL_LevelTravel:(TreeNode *)tree {
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
            NSString *info = [NSString stringWithFormat:@" (%@ %ld %@) ", node.data, node.height, node.parent.data];
            [result appendFormat:@" %@ ", info];
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

- (NSInteger)check_AVLTree:(TreeNode *)tree {
    if (!tree) {
        return 0;
    }
    __weak typeof(self) weakSelf = self;
    void(^printBlock)(TreeNode* node, NSString *reason) = ^(TreeNode *node, NSString *reason) {
        TreeNode *root = node;
        while (root.parent) {
            root = root.parent;
        }
        [weakSelf AVL_LevelTravel:root];
        NSString *res = [NSString stringWithFormat:@"rb_tree condition error! %@", reason];
        NSAssert(0, res);
        
    };
    NSInteger leftH = [self check_AVLTree:tree.left];
    NSInteger rightH = [self check_AVLTree:tree.right];
    if (leftH - rightH >=2 || rightH - leftH >= 2) {
        printBlock(tree, @"height");
    }
    if ((tree.left && tree.data < tree.left.data) || (tree.right && tree.data > tree.right.data)) {
        printBlock(tree, @"value");
    }
    return MAX(leftH, rightH) + 1;
}
@end
