//
//  main.m
//  debug-objc
//
//  Created by suchavision on 1/24/17.
//
//

#import <Foundation/Foundation.h>
#import <OCTestRunTime.h>
#import <BaseGrammarTest.h>
#import <WxKvcTestClass.h>
#import <DispatchQueueTest.h>
#import "OCRunLoopTest.h"
#import "OcBlockTest.h"
#import "WxHttpRequestMgr.h"
#import "WxAlogrithmSet.h"
#include "WxRedBlackTree.h"
#import "WxAVLTree.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        [OCTestRunTime testMessageSend];
//        [[BaseGrammarTest sharedInstance] startTask];
//        [OcBlockTest startTest];
          [OCRunLoopTest new];
//        [WxKvcTestClass startTest];
//        [[DispatchQueueTest new] startTest];
//        [WxAlogrithmSet startTest];
//        [WxRedBlackTree startTest];
//        [WxAVLTree startTest];
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
    }
    return 0;
}
