//
//  MJKTaskQueue.h
//  MJKScheduler
//
//  Created by Ansel on 2019/7/12.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MJKTaskPriority) {
    MJKTaskPriorityLow = -4L,
    MJKTaskPriorityNormal = 0,
    MJKTaskPriorityHigh = 4,
    MJKTaskPriorityVeryHigh = 8
};

typedef NS_ENUM(NSInteger, MJKTaskStatus) {
    MJKTaskStatusNoraml = 0,
    MJKTaskStatusExecuting = 1,
    MJKTaskStatusCompleted = 2,
    MJKTaskStatusCanceled = 3,
    
    MJKTaskStatusAll
};

typedef void(^MJKTaskCompletedCallback)(void);
typedef void(^MJKTaskBlock)(_Nonnull MJKTaskCompletedCallback completedCallback);

NS_ASSUME_NONNULL_BEGIN

@interface MJKTask : NSObject

@property(nonatomic, copy, readonly) MJKTaskBlock taskBlock;
@property(nonatomic, assign, readonly) MJKTaskPriority priority;
@property(nonatomic, copy, readonly) NSString *identifier;
@property(nonatomic, assign, readonly, getter=isInMainThread) BOOL inMainThread;
@property(nonatomic, assign, readonly) MJKTaskStatus status;

/*
 默认在子线程执行
*/
- (instancetype)initWithTaskBlock:(MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier;
- (instancetype)initWithTaskBlock:(MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier inMainThread:(BOOL)inMainThread NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

@property(nonatomic, copy, readonly) NSArray<MJKTask *> *dependencyTasks;
- (void)addDependencyTask:(MJKTask *)task;
- (void)removeDependencyTask:(MJKTask *)task;
- (void)addDependencyTasks:(NSArray<MJKTask *> *)tasks;
- (void)removeDependencyTasks:(NSArray<MJKTask *> *)tasks;

- (void)tryCompleted;

@end

/**
 相同的优先级全部执行之后才会执行下一个优先级的Task
 */
@interface MJKTaskQueue : NSObject

@property(nonatomic, assign) NSInteger maxConcurrentOperationCount;
@property(nonatomic, assign, getter=isSuspend) BOOL suspend;

/*
 默认在子线程执行
*/
- (MJKTask *)addTaskWithTaskBlock:(nonnull MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier;
- (MJKTask *)addTaskWithTaskBlock:(nonnull MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier inMainThread:(BOOL)inMainThread;
- (void)addTask:(nonnull MJKTask *)task;
- (void)removeTask:(nonnull MJKTask *)task;
- (void)removeAllTasks;

- (void)forceExectueTasks:(nonnull NSArray<MJKTask *> *)tasks;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
