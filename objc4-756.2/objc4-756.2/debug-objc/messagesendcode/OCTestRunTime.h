//
//  OCTestRunTime.h
//  testcode
//
//  Created by wqan3313 on 2018/5/16.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjcHelpFunc.h"
#import "Person.h"

@interface Student : Person
@end


@interface Friend : Person
@property (nonatomic, strong)Student *schoolMate;
@end

@interface OCTestRunTime : NSObject
{
    NSInteger testTime;
    id selfData;
};

+ (void)testMessageSend;

@end
