//
//  WxStack.m
//  debug-objc
//
//  Created by wqa on 2018/11/10.
//

#import "WxStack.h"

@interface WxStack<ObjectType> ()
@property(nonatomic, strong)NSMutableArray<ObjectType> *stack;
@end

@implementation WxStack

- (instancetype)init {
    if (self = [super init]) {
        self.stack = [NSMutableArray new];
    }
    return self;
}

- (void)push:(id)obj {
    [self.stack addObject:obj];
}

- (id)pop {
    if (self.empty) {
        return nil;
    }
    id obj = [self.stack lastObject];
    [self.stack removeLastObject];
    return obj;
}

- (BOOL)empty {
    return (self.stack.count == 0);
}

- (id)top {
    if (self.empty) {
        return nil;
    }
    return self.stack.lastObject;
}

- (int)size {
    return self.stack.count;
}

- (NSArray *)curStackToArry {
    return [NSArray arrayWithArray:self.stack];
}
@end
