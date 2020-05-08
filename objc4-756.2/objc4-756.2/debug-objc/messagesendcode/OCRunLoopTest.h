//
//  OCRunLoopTest.h
//  debug-objc
//
//  Created by mac on 2018/9/28.
//

#import <Foundation/Foundation.h>

@interface OCRunLoopTest : NSObject

@property (nonatomic, strong) NSThread *threadA;

@property (nonatomic, strong) NSThread *threadB;

@property (nonatomic, strong) NSThread *threadC;
@end

/*
static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
    uint64_t startTSR = mach_absolute_time();//获取系统启动之后 的内核时间
    
    //如果当前runLoop或者runLoopMode为停止状态的话直接返回
    if (__CFRunLoopIsStopped(rl)) {
        __CFRunLoopUnsetStopped(rl);
        return kCFRunLoopRunStopped;
    } else if (rlm->_stopped) {
        rlm->_stopped = false;
        return kCFRunLoopRunStopped;
    }
    
    mach_port_name_t dispatchPort = MACH_PORT_NULL;//用来保存主队列（mainQueue）的端口。mach端口--线程之间通信
    //判断当前线程是否主线程（当前runloop是否主线程runloop），如果是就分发一个队列调度端口
    Boolean libdispatchQSafe = pthread_main_np() && ((HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && NULL == previousMode) || (!HANDLE_DISPATCH_ON_BASE_INVOCATION_ONLY && 0 == _CFGetTSD(__CFTSDKeyIsInGCDMainQ)));
    // 只有在MainRunLoop，才会有下面这行赋值，否则 dispatchPort 为NULL
    if (libdispatchQSafe && (CFRunLoopGetMain() == rl) && CFSetContainsValue(rl->_commonModes, rlm->_name))
        dispatchPort = _dispatch_get_main_queue_port_4CF();
    
    
#if USE_DISPATCH_SOURCE_FOR_TIMERS
    //给当前mode分发队列端口
    mach_port_name_t modeQueuePort = MACH_PORT_NULL;
    if (rlm->_queue) {
        modeQueuePort = _dispatch_runloop_root_queue_get_port_4CF(rlm->_queue);
        if (!modeQueuePort) {
            CRASH("Unable to get port for run loop mode queue (%d)", -1);
        }
    }
#endif
    //gcd有关的东西，实现runloop超时管理。

     struct __timeout_context {
     dispatch_source_t ds;
     CFRunLoopRef rl;//runloop
     uint64_t termTSR;//超时时间点？
     };

    //对gcd的一些api不是很熟悉，但大概看懂是主要通过dispatch_source_t创建计时器；精度很高，系统自动触发，是系统级别的源
    dispatch_source_t timeout_timer = NULL;
    struct __timeout_context *timeout_context = (struct __timeout_context *)malloc(sizeof(*timeout_context));//超时上下文
    if (seconds <= 0.0) { //seconds：设置的runloop超时时间
        seconds = 0.0;
        timeout_context->termTSR = 0ULL;
    } else if (seconds <= TIMER_INTERVAL_LIMIT) {//设置的超时时间在最大限制内，才创建timeout_timer
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, DISPATCH_QUEUE_OVERCOMMIT);
        timeout_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_retain(timeout_timer);
        timeout_context->ds = timeout_timer;
        timeout_context->rl = (CFRunLoopRef)CFRetain(rl);
        timeout_context->termTSR = startTSR + __CFTimeIntervalToTSR(seconds);
        dispatch_set_context(timeout_timer, timeout_context); //绑定// source gets ownership of context
        dispatch_source_set_event_handler_f(timeout_timer, __CFRunLoopTimeout);
        dispatch_source_set_cancel_handler_f(timeout_timer, __CFRunLoopTimeoutCancel);
        uint64_t ns_at = (uint64_t)((__CFTSRToTimeInterval(startTSR) + seconds) * 1000000000ULL);
        dispatch_source_set_timer(timeout_timer, dispatch_time(1, ns_at), DISPATCH_TIME_FOREVER, 1000ULL);
        dispatch_resume(timeout_timer);
    } else { // infinite timeout 超时时间无穷尽
        seconds = 9999999999.0;
        timeout_context->termTSR = UINT64_MAX;
    }
    
    Boolean didDispatchPortLastTime = true;
    int32_t retVal = 0;
    do {
        uint8_t msg_buffer[3 * 1024];
        mach_msg_header_t *msg = NULL;
        mach_port_t livePort = MACH_PORT_NULL;
        __CFPortSet waitSet = rlm->_portSet;//_portSet：记录了所有当前mode中需要监听的port，作为调用监听消息函数的参数。
        
        __CFRunLoopUnsetIgnoreWakeUps(rl);//不忽略端口唤醒
        //2. 通知Observers:通知即将处理timer
        if (rlm->_observerMask & kCFRunLoopBeforeTimers) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers);
        //3. 通知Observers:通知即将处理Source0(非port)。
        if (rlm->_observerMask & kCFRunLoopBeforeSources) __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);
        
        //处理加入到runLoop中的block。（非延迟的主线程？）
        __CFRunLoopDoBlocks(rl, rlm);
        //4.处理source0事件  UItouch uievent selector
        Boolean sourceHandledThisLoop = __CFRunLoopDoSources0(rl, rlm, stopAfterHandle);
        //处理block
        if (sourceHandledThisLoop) {
            __CFRunLoopDoBlocks(rl, rlm);
        }
        
        //poll标志着有没有处理source0的消息，如果没有则为false，反之为true
        //poll=NO的情况：没有source0且超时时间!=0
        Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);//(后一条件似乎是必然为false的)
        
        //主线程runloop 端口存在、didDispatchPortLastTime为假（首次执行不会进入判断，因为didDispatchPortLastTime为true）
        if (MACH_PORT_NULL != dispatchPort && !didDispatchPortLastTime) {
            msg = (mach_msg_header_t *)msg_buffer;
            //__CFRunLoopServiceMachPort用于接受指定端口(一个也可以是多个)的消息,最后一个参数代表当端口无消息的时候是否休眠,0是立刻返回不休眠,TIMEOUT_INFINITY代表休眠
            //处理通过GCD派发到主线程的任务,这些任务优先级最高会被最先处理
            //5.如果有Source1，就直接跳转去处理消息。（文档说是检测source1，不过源码看来是检测dispatchPort---gcd端口事件）
            if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0)) {
                goto handle_msg;//如果端口有事件则跳转至handle_msg
            }
        }
        
        didDispatchPortLastTime = false;
        
        //之前没有处理过source0，也没有source1消息，就让线程进入睡眠。
        //6.通知 Observers: RunLoop 的线程即将进入休眠
        if (!poll && (rlm->_observerMask & kCFRunLoopBeforeWaiting))
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
        // 标志当前runLoop为休眠状态
        __CFRunLoopSetSleeping(rl);
        
        __CFPortSetInsert(dispatchPort, waitSet);
        
        __CFRunLoopModeUnlock(rlm);
        __CFRunLoopUnlock(rl);
        
#if USE_DISPATCH_SOURCE_FOR_TIMERS
        //  进入循环开始不断的读取端口信息，如果端口有唤醒信息则唤醒当前runLoop
        do {
            if (kCFUseCollectableAllocator) {
                objc_clear_stack(0);
                memset(msg_buffer, 0, sizeof(msg_buffer));
            }
            msg = (mach_msg_header_t *)msg_buffer;
            //7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
            /// • 一个基于 port 的Source 的事件。
            /// • 一个 Timer 到时间了
            /// • RunLoop 自身的超时时间到了
            /// • 被其他什么调用者手动唤醒
            
            //如果poll为no，且waitset中无port有消息,线程进入休眠；否则唤醒
            __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY);
            //livePort是modeQueuePort，则代表为当前mode队列的端口
            if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) {
                //不太懂
                while (_dispatch_runloop_root_queue_perform_4CF(rlm->_queue));
                //知道Timer被激活了才跳出二级循环继续循环一级循环
                if (rlm->_timerFired) {
                    rlm->_timerFired = false;
                    break;
                } else {
                    if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
                }
            }
            //如果livePort不为modeQueuePort，runLoop被唤醒。这代表__CFRunLoopServiceMachPort给出的livePort只有两种可能：一种情况为MACH_PORT_NULL，另一种为真正获取的消息的端口。
            else {
                // Go ahead and leave the inner loop.
                break;
            }
        } while (1);
#else
        if (kCFUseCollectableAllocator) {
            objc_clear_stack(0);
            memset(msg_buffer, 0, sizeof(msg_buffer));
        }
        msg = (mach_msg_header_t *)msg_buffer;
        __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY);
#endif
        
        __CFRunLoopLock(rl);
        __CFRunLoopModeLock(rlm);
        __CFPortSetRemove(dispatchPort, waitSet);
        //忽略端口唤醒
        __CFRunLoopSetIgnoreWakeUps(rl);
        // user callouts now OK again
        __CFRunLoopUnsetSleeping(rl);
        //8.通知 Observers:RunLoop的线程刚刚被唤醒了。
        if (!poll && (rlm->_observerMask & kCFRunLoopAfterWaiting))
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);
        
        //处理端口消息
    handle_msg:;
        __CFRunLoopSetIgnoreWakeUps(rl);//设置此时runLoop忽略端口唤醒（保证线程安全）
        
        
        // 9.处理待处理的事件
        if (MACH_PORT_NULL == livePort) {//什么都不做（超时或..?
            CFRUNLOOP_WAKEUP_FOR_NOTHING();
            // handle nothing
        }
        //struct __CFRunLoop中有这么一项：__CFPort _wakeUpPort，用于手动将当前runloop线程唤醒，通过调用CFRunLoopWakeUp完成，CFRunLoopWakeUp会向_wakeUpPort发送一条消息
        else if (livePort == rl->_wakeUpPort) {//只有外界调用CFRunLoopWakeUp才会进入此分支，这是外部主动唤醒runLoop的接口
            CFRUNLOOP_WAKEUP_FOR_WAKEUP();//唤醒
            // do nothing on Mac OS
        }
#if USE_DISPATCH_SOURCE_FOR_TIMERS
        else if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) {
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
                // Re-arm the next timer, because we apparently fired early
                __CFArmNextTimerInMode(rlm, rl);
            }
        }
#endif
#if USE_MK_TIMER_TOO
        //处理因timer的唤醒。9.1 如果一个 Timer 到时间了，触发这个Timer的回调。
        else if (rlm->_timerPort != MACH_PORT_NULL && livePort == rlm->_timerPort) {
            CFRUNLOOP_WAKEUP_FOR_TIMER();
            if (!__CFRunLoopDoTimers(rl, rlm, mach_absolute_time())) {
                // Re-arm the next timer
                __CFArmNextTimerInMode(rlm, rl);
            }
        }
#endif
        else if (livePort == dispatchPort) {
            CFRUNLOOP_WAKEUP_FOR_DISPATCH();
            __CFRunLoopModeUnlock(rlm);
            __CFRunLoopUnlock(rl);
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)6, NULL);
            
            //9.2处理异步方法唤醒。处理gcd dispatch到main_queue的block，执行block。
            //有判断是否是在MainRunLoop，有获取Main_Queue 的port，并且有调用 Main_Queue 上的回调，这只能是是 GCD 主队列上的异步任务。即：dispatch_async(dispatch_get_main_queue(), block)产生的任务。
 
            __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            _CFSetTSD(__CFTSDKeyIsInGCDMainQ, (void *)0, NULL);
            __CFRunLoopLock(rl);
            __CFRunLoopModeLock(rlm);
            sourceHandledThisLoop = true;
            didDispatchPortLastTime = true;
        } else {
            // 9.3处理Source1 (基于port)
            CFRUNLOOP_WAKEUP_FOR_SOURCE();
            // Despite the name, this works for windows handles as well
            //过滤macPort消息，有一些消息不一定是runloop中注册的，这里只处理runloop中注册的消息，在rlm->_portToV1SourceMap通过macPort找有没有对应的runloopMode
            CFRunLoopSourceRef rls = __CFRunLoopModeFindSourceForMachPort(rl, rlm, livePort);
            if (rls) {
                mach_msg_header_t *reply = NULL;
                // 处理Source1
                sourceHandledThisLoop = __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply) || sourceHandledThisLoop;
                if (NULL != reply) {
                    //当前线程处理完source1，给发消息的线程反馈消息
                    (void)mach_msg(reply, MACH_SEND_MSG, reply->msgh_size, 0, MACH_PORT_NULL, 0, MACH_PORT_NULL);
                    CFAllocatorDeallocate(kCFAllocatorSystemDefault, reply);
                }
            }
        }
#if DEPLOYMENT_TARGET_MACOSX || DEPLOYMENT_TARGET_EMBEDDED || DEPLOYMENT_TARGET_EMBEDDED_MINI
        if (msg && msg != (mach_msg_header_t *)msg_buffer) free(msg);
#endif
        //block处理
        __CFRunLoopDoBlocks(rl, rlm);
        
        // 进入loop时参数说处理完事件就返回。
        if (sourceHandledThisLoop && stopAfterHandle) {
            retVal = kCFRunLoopRunHandledSource;
        }
        // 超出传入参数标记的超时时间了
        else if (timeout_context->termTSR < mach_absolute_time()) {
            retVal = kCFRunLoopRunTimedOut;
        }
        // 被外部调用者强制停止了
        else if (__CFRunLoopIsStopped(rl)) {
            __CFRunLoopUnsetStopped(rl);
            retVal = kCFRunLoopRunStopped;
        } else if (rlm->_stopped) {
            rlm->_stopped = false;
            retVal = kCFRunLoopRunStopped;
        }
        // source/timer/observer一个都没有了
        else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
            retVal = kCFRunLoopRunFinished;
        }
        // 如果没超时，mode里没空，loop也没被停止，那继续loop。
    } while (0 == retVal);
    
    //释放定时器
    if (timeout_timer) {
        dispatch_source_cancel(timeout_timer);
        dispatch_release(timeout_timer);
    } else {
        free(timeout_context);
    }
    
    return retVal;
}

*/
