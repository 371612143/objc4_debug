//
//  BaseGrammarTest.h
//  testcode
//
//  Created by wqan3313 on 2018/5/18.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseGrammarTest : NSObject
+ (instancetype)sharedInstance;
- (void)startTask;
- (void)stopTask;
@property (weak)id weakData;
@end
