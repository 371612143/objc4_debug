//
//  DispatchQueueTest.h
//  testcode
//
//  Created by wqan3313 on 2018/5/31.
//  Copyright © 2018年 wqan3313. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dispatch/source.h>

#ifndef __DISPATCH_SHIMS_ATOMIC__
#define __DISPATCH_SHIMS_ATOMIC__

#if !__has_extension(c_atomic) || !__has_include(<stdatomic.h>)
#error libdispatch requires C11 with <stdatomic.h>
#endif

#include <stdatomic.h>

#define memory_order_ordered    memory_order_seq_cst
#define memory_order_dependency memory_order_acquire

#define os_atomic(type) type _Atomic

#define _os_atomic_c11_atomic(p) \
((typeof(*(p)) _Atomic *)(p))

// This removes the _Atomic and volatile qualifiers on the type of *p
#define _os_atomic_basetypeof(p) \
typeof(atomic_load_explicit(_os_atomic_c11_atomic(p), memory_order_relaxed))

//返回*p
#define os_atomic_load(p, m) \
atomic_load_explicit(_os_atomic_c11_atomic(p), memory_order_##m)
//*p = e
#define os_atomic_store(p, v, m) \
atomic_store_explicit(_os_atomic_c11_atomic(p), v, memory_order_##m)
//*p = v; 返回*p的旧值
#define os_atomic_xchg(p, v, m) \
atomic_exchange_explicit(_os_atomic_c11_atomic(p), v, memory_order_##m)
//v比较*p==e 相等则 *p = new,返回1 否则返回0
#define os_atomic_cmpxchg(p, e, v, m) \
({ _os_atomic_basetypeof(p) _r = (e); \
atomic_compare_exchange_strong_explicit(_os_atomic_c11_atomic(p), \
&_r, v, memory_order_##m, memory_order_relaxed); })
//v比较*p==e 相等则 *p = new, *g = e返回1 否则返回0
#define os_atomic_cmpxchgv(p, e, v, g, m) \
({ _os_atomic_basetypeof(p) _r = (e); _Bool _b = \
atomic_compare_exchange_strong_explicit(_os_atomic_c11_atomic(p), \
&_r, v, memory_order_##m, memory_order_relaxed); *(g) = _r; _b; })
//v比较*p==e 相等则 *p = new, *g = e返回1 否则返回0
#define os_atomic_cmpxchgvw(p, e, v, g, m) \
({ _os_atomic_basetypeof(p) _r = (e); _Bool _b = \
atomic_compare_exchange_weak_explicit(_os_atomic_c11_atomic(p), \
&_r, v, memory_order_##m, memory_order_relaxed); *(g) = _r;  _b; })

//*p = *p op v, 返回新值
#define _os_atomic_c11_op(p, v, m, o, op) \
({ _os_atomic_basetypeof(p) _v = (v), _r = \
atomic_fetch_##o##_explicit(_os_atomic_c11_atomic(p), _v, \
memory_order_##m); (typeof(_r))(_r op _v); })
//*p = *p op v, 返回旧值
#define _os_atomic_c11_op_orig(p, v, m, o, op) \
atomic_fetch_##o##_explicit(_os_atomic_c11_atomic(p), v, \
memory_order_##m)
//*p = *p + v 返回新值  下面是+，-，&，|， ^等操作
#define os_atomic_add(p, v, m) \
_os_atomic_c11_op((p), (v), m, add, +)
#define os_atomic_add_orig(p, v, m) \
_os_atomic_c11_op_orig((p), (v), m, add, +)
#define os_atomic_sub(p, v, m) \
_os_atomic_c11_op((p), (v), m, sub, -)
#define os_atomic_sub_orig(p, v, m) \
_os_atomic_c11_op_orig((p), (v), m, sub, -)
#define os_atomic_and(p, v, m) \
_os_atomic_c11_op((p), (v), m, and, &)
#define os_atomic_and_orig(p, v, m) \
_os_atomic_c11_op_orig((p), (v), m, and, &)
#define os_atomic_or(p, v, m) \
_os_atomic_c11_op((p), (v), m, or, |)
#define os_atomic_or_orig(p, v, m) \
_os_atomic_c11_op_orig((p), (v), m, or, |)
#define os_atomic_xor(p, v, m) \
_os_atomic_c11_op((p), (v), m, xor, ^)
#define os_atomic_xor_orig(p, v, m) \
_os_atomic_c11_op_orig((p), (v), m, xor, ^)

#define os_atomic_force_dependency_on(p, e) (p)
#define os_atomic_load_with_dependency_on(p, e) \
os_atomic_load(os_atomic_force_dependency_on(p, e), relaxed)
#define os_atomic_load_with_dependency_on2o(p, f, e) \
os_atomic_load_with_dependency_on(&(p)->f, e)

#define os_atomic_thread_fence(m)  atomic_thread_fence(memory_order_##m)
//os_atomic_xxxx2o(p, f, e, v, m) 等同于 os_atomic_xxx(p->f, e, v, m)
#define os_atomic_load2o(p, f, m) \
os_atomic_load(&(p)->f, m)
#define os_atomic_store2o(p, f, v, m) \
os_atomic_store(&(p)->f, (v), m)
#define os_atomic_xchg2o(p, f, v, m) \
os_atomic_xchg(&(p)->f, (v), m)
#define os_atomic_cmpxchg2o(p, f, e, v, m) \
os_atomic_cmpxchg(&(p)->f, (e), (v), m)
#define os_atomic_cmpxchgv2o(p, f, e, v, g, m) \
os_atomic_cmpxchgv(&(p)->f, (e), (v), (g), m)
#define os_atomic_cmpxchgvw2o(p, f, e, v, g, m) \
os_atomic_cmpxchgvw(&(p)->f, (e), (v), (g), m)
#define os_atomic_add2o(p, f, v, m) \
os_atomic_add(&(p)->f, (v), m)
#define os_atomic_add_orig2o(p, f, v, m) \
os_atomic_add_orig(&(p)->f, (v), m)
#define os_atomic_sub2o(p, f, v, m) \
os_atomic_sub(&(p)->f, (v), m)
#define os_atomic_sub_orig2o(p, f, v, m) \
os_atomic_sub_orig(&(p)->f, (v), m)
#define os_atomic_and2o(p, f, v, m) \
os_atomic_and(&(p)->f, (v), m)
#define os_atomic_and_orig2o(p, f, v, m) \
os_atomic_and_orig(&(p)->f, (v), m)
#define os_atomic_or2o(p, f, v, m) \
os_atomic_or(&(p)->f, (v), m)
#define os_atomic_or_orig2o(p, f, v, m) \
os_atomic_or_orig(&(p)->f, (v), m)
#define os_atomic_xor2o(p, f, v, m) \
os_atomic_xor(&(p)->f, (v), m)
#define os_atomic_xor_orig2o(p, f, v, m) \
os_atomic_xor_orig(&(p)->f, (v), m)

#define os_atomic_inc(p, m) \
os_atomic_add((p), 1, m)
#define os_atomic_inc_orig(p, m) \
os_atomic_add_orig((p), 1, m)
#define os_atomic_inc2o(p, f, m) \
os_atomic_add2o(p, f, 1, m)
#define os_atomic_inc_orig2o(p, f, m) \
os_atomic_add_orig2o(p, f, 1, m)
#define os_atomic_dec(p, m) \
os_atomic_sub((p), 1, m)
#define os_atomic_dec_orig(p, m) \
os_atomic_sub_orig((p), 1, m)
#define os_atomic_dec2o(p, f, m) \
os_atomic_sub2o(p, f, 1, m)
#define os_atomic_dec_orig2o(p, f, m) \
os_atomic_sub_orig2o(p, f, 1, m)

//第一次运行后ov=*p, *p = nv, 如果ov!=*p,则继续运行 即在执行block过程中ov被改变
#define os_atomic_rmw_loop(p, ov, nv, m, ...)  ({ \
bool _result = false; \
typeof(p) _p = (p); \
ov = os_atomic_load(_p, relaxed); \
do { \
__VA_ARGS__; \
_result = os_atomic_cmpxchgvw(_p, ov, nv, &ov, m); \
} while (os_unlikely(!_result)); \
_result; \
})
#define os_atomic_rmw_loop2o(p, f, ov, nv, m, ...) \
os_atomic_rmw_loop(&(p)->f, ov, nv, m, __VA_ARGS__)
#define os_atomic_rmw_loop_give_up_with_fence(m, expr) \
({ os_atomic_thread_fence(m); expr; __builtin_unreachable(); })
#define os_atomic_rmw_loop_give_up(expr) \
os_atomic_rmw_loop_give_up_with_fence(relaxed, expr)

#endif // __DISPATCH_SHIMS_ATOMIC__


@interface DispatchQueueTest : NSObject
{
    dispatch_source_t timer;
};

- (void)startTest;

@property (nonatomic, weak)NSObject *weakObj;
@property (nonatomic, strong)NSObject *strongObj;
@property (nonatomic, copy)NSObject *cpObj;
@end
