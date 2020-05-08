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
#import <malloc/malloc.h>

typedef struct my_zone {
    malloc_zone_t basic_zone;
}my_zone_t;

static void *my_malloc(malloc_zone_t *szone, size_t size) {
    return nil;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        my_zone_t *mzone = new my_zone_t;
        malloc_zone_t *newZone = malloc_create_zone(PAGE_SIZE*2, 0);
        mzone->basic_zone.malloc = my_malloc;
        malloc_zone_t *defaultZone = malloc_default_zone();
        malloc_zone_register((malloc_zone_t *)mzone);
        malloc_zone_unregister(defaultZone);
        malloc_zone_unregister((malloc_zone_t *)mzone);
        malloc_zone_t *newdefaultZone = malloc_default_zone();
        void *p = malloc(12);
        void *p2 = malloc_zone_malloc((malloc_zone_t *)mzone, 1);
        malloc_zone_register(defaultZone);
        [OCTestRunTime testMessageSend];
        [[BaseGrammarTest sharedInstance] startTask];
        [OcBlockTest startTest];
        [OCRunLoopTest new];
        [WxKvcTestClass startTest];
        [[DispatchQueueTest new] startTest];
        [WxAlogrithmSet startTest];
        [WxRedBlackTree startTest];
        [WxAVLTree startTest];

        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
    }

    return 0;
}
