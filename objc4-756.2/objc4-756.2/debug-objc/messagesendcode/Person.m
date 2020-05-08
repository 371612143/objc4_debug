//
//  Person.m
//  testcode
//
//  Created by wqan3313 on 2018/5/15.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import "Person.h"
#import "OCTestRunTime.h"



@implementation Parent

@end

@implementation Person

+ (void)load {  //[person load] ->[person initialize] -> [Friend initialize] -> [friend load]
    NSLog(@"Person running fmethod %@", NSStringFromSelector(_cmd));
    [Friend class];
    [Person class];
    //Friend *f = [Friend new];
    //[f gotoSchool];
}

+ (void) initialize {
    NSLog(@"Person running fmethod %@", NSStringFromSelector(_cmd));
}

- (instancetype)init {
    if (self = [super init]) {
        self.name = @"somebody";
    }
    return self;
}

- (void)walk {
    NSLog(@"Person running fmethod %@", NSStringFromSelector(_cmd));
}
@end
