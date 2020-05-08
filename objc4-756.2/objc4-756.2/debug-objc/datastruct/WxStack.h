//
//  WxStack.h
//  debug-objc
//
//  Created by wqa on 2018/11/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WxStack<ObjectType> : NSObject
- (void)push:(ObjectType)obj;
- (ObjectType)pop;
- (NSArray *)curStackToArry;

@property (nonatomic, assign, readonly)BOOL empty;
@property (nonatomic, strong, readonly)ObjectType top;
@property (nonatomic, assign, readonly)int size;
@end

NS_ASSUME_NONNULL_END
