//
//  OcBlockTest.h
//  debug-objc
//
//  Created by mac on 2018/9/30.
//
#import <Foundation/Foundation.h>
typedef void(^onAnimationFinishedBlock)(int a, int b);

@interface OcBlockTest : NSObject
+ (void)startTest;
+ (void)stopTest;
@end
