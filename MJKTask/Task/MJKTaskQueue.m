//
//  MJKTaskQueue.m
//  MJKScheduler
//
//  Created by Ansel on 2019/7/12.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "MJKTaskQueue.h"

static NSInteger const WMDefaultMaxConcurrentOperationCount = 5;

@interface MJKTask ()<NSCopying>

@property(nonatomic, copy) MJKTaskBlock taskBlock;
@property(nonatomic, assign) MJKTaskPriority priority;
@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, assign) BOOL inMainThread;
@property(nonatomic, assign) MJKTaskStatus status;

///没有参与copyy协议
@property(nonatomic, copy) MJKTaskCompletedCallback completedCallback;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableArray<MJKTask *> *innerdependencyTasks;
//没有参与copyy协议 end

@end

@implementation MJKTask

- (instancetype)initWithTaskBlock:(MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier {
    return [self initWithTaskBlock:taskBlock priority:priority identifier:identifier inMainThread:NO];
}

- (instancetype)initWithTaskBlock:(MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier inMainThread:(BOOL)inMainThread {
    self = [super init];
    if (self) {
        self.taskBlock = taskBlock;
        self.priority = priority;
        self.identifier = identifier;
        self.inMainThread = inMainThread;
        
        self.semaphore = dispatch_semaphore_create(1);
        self.innerdependencyTasks = [[NSMutableArray alloc] init];
        self.status = MJKTaskStatusNoraml;
    }
    
    return self;
}

- (void)addDependencyTask:(MJKTask *)task {
    [self safeExecuteBlock:^{
        [self.innerdependencyTasks addObject:task];
    }];
}

- (void)removeDependencyTask:(MJKTask *)task {
    [self safeExecuteBlock:^{
        [self.innerdependencyTasks removeObject:task];
    }];
}

- (void)addDependencyTasks:(NSArray<MJKTask *> *)tasks {
    [self safeExecuteBlock:^{
        [self.innerdependencyTasks addObjectsFromArray:tasks];
    }];
}

- (void)removeDependencyTasks:(NSArray<MJKTask *> *)tasks {
    [self safeExecuteBlock:^{
        [self.innerdependencyTasks removeObjectsInArray:tasks];
    }];
}

- (void)tryCompleted {
    if (self.status == MJKTaskStatusCompleted) {
        return;
    }
    
    self.status = MJKTaskStatusCompleted;
    if (self.completedCallback) {
        self.completedCallback();
    }
}

#pragma mark - Property

- (NSArray<MJKTask *> *)dependencyTasks {
    NSMutableArray<MJKTask *> *tempDependencyTasks = @[].mutableCopy;
    [self safeExecuteBlock:^{
        [self.innerdependencyTasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull launchTask, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempDependencyTasks addObject:[launchTask copy]];
        }];
    }];
    
    return tempDependencyTasks;
}

#pragma mark - Override

- (NSUInteger)hash {
    NSString *stringToHash = [NSString stringWithFormat:@"%@_%zd_%@", [self class], self.priority, self.identifier];
    return [stringToHash hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isMemberOfClass:[self class]]) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
   
    MJKTask *task = (MJKTask *)object;
    if ((self.priority == task.priority) &&
        [self.identifier isEqualToString:task.identifier]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    MJKTask *task = [[[self class] allocWithZone:zone] init];
    task.taskBlock = [self.taskBlock copy];
    task.priority = self.priority;
    task.identifier = [self.identifier copy];
    task.inMainThread = self.inMainThread;
    task.status = self.status;
    
    return task;
}

#pragma mark - PrivateMethod

- (void)safeExecuteBlock:(void(^)(void))block {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    if (block) {
        block();
    }
    
    dispatch_semaphore_signal(self.semaphore);
}

@end

@interface MJKTaskQueue ()

@property(nonatomic, strong) NSMutableArray<MJKTask *> *tasks;
@property(nonatomic, strong) NSMutableArray<MJKTask *> *executingTasks;

@property(nonatomic, strong) NSOperationQueue *operationQueue; //处理异步任务 简单粗暴最大并发数直接等于TaskQueue的最大并发数
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation MJKTaskQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tasks = [[NSMutableArray alloc] init];
        self.executingTasks = [[NSMutableArray alloc] init];

        self.operationQueue = [[NSOperationQueue alloc] init];
        self.semaphore = dispatch_semaphore_create(1);
        
        self.suspend = NO;
        self.maxConcurrentOperationCount = WMDefaultMaxConcurrentOperationCount;
    }
    
    return self;
}

- (MJKTask *)addTaskWithTaskBlock:(nonnull MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier {
    return [self addTaskWithTaskBlock:taskBlock priority:priority identifier:identifier inMainThread:NO];
}

- (MJKTask *)addTaskWithTaskBlock:(nonnull MJKTaskBlock)taskBlock priority:(MJKTaskPriority)priority identifier:(NSString *)identifier inMainThread:(BOOL)inMainThread {
    MJKTask *task = [[MJKTask alloc] initWithTaskBlock:taskBlock priority:priority identifier:identifier inMainThread:inMainThread];
    [self addTask:task];
   
    return task;
}

- (void)addTask:(MJKTask *)task {
    if (!task) {
        return;
    }
    
    [self safeExecuteBlock:^{
        if ([self.tasks containsObject:task] || [self.executingTasks containsObject:task]) {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(task) weakTask = task;
        [task setCompletedCallback:^{
            [weakSelf safeExecuteBlock:^{
                if (!weakTask) {
                    return;
                }
                
                [weakSelf.executingTasks removeObject:weakTask];
                [weakSelf.tasks removeObject:weakTask];
            }];
            
            [weakSelf continueExecuteTasks];
        }];
        
        __block NSInteger index = 0;
        [self.tasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.priority < task.priority) {
                *stop = YES;
                return;
            }
            
            ++index;
        }];
        
        [self.tasks insertObject:task atIndex:index];
    }];
    
    [self continueExecuteTasks];
}

- (void)removeTask:(MJKTask *)task {
    if (!task) {
        return;
    }
    
    [self safeExecuteBlock:^{
        [task setStatus:MJKTaskStatusCanceled];
        [self.tasks removeObject:task];
    }];
}

- (void)removeAllTasks {
    [self safeExecuteBlock:^{
        [self.tasks removeAllObjects];
    }];
}

- (void)forceExectueTasks:(nonnull NSArray<MJKTask *> *)tasks {
    if ([tasks count] <= 0) {
        return;
    }
    
    [self safeExecuteBlock:^{
        [tasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.executingTasks containsObject:task]) {
                return;
            }
            
            if ([self.tasks containsObject:task]) {
                [self.tasks removeObject:task];
            }
            
            if (task.taskBlock) {
                task.taskBlock(^{
                    
                });
            }
        }];
    }];
}

- (void)reset {
    [self safeExecuteBlock:^{
        [self.tasks removeAllObjects];
        [self.executingTasks removeAllObjects];
    }];
}

#pragma mark - Property

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount {
    if (_maxConcurrentOperationCount == maxConcurrentOperationCount) {
        return;
    }
    
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    [self.operationQueue setMaxConcurrentOperationCount:_maxConcurrentOperationCount];
}

- (void)setSuspend:(BOOL)suspend {
    if(_suspend == suspend) {
        return;
    }
    
    _suspend = suspend;
    
    if (_suspend) {
        return;
    }
    
    [self continueExecuteTasks];
}

#pragma mark - PrivateMethod

- (void)safeExecuteBlock:(void(^)(void))block {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    if (block) {
        block();
    }
    
    dispatch_semaphore_signal(self.semaphore);
}

- (void)continueExecuteTasks {
    if (self.isSuspend) {
        return;
    }
    
    NSMutableArray<MJKTask *> *willExecuteTasks = [[NSMutableArray alloc] init];
    [self safeExecuteBlock:^{
        if ([self.tasks count] <= 0) {
            return;
        }
        
        [self.tasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.executingTasks count] >= self.maxConcurrentOperationCount) {
                *stop = YES;
                return;
            }
            
            //为了性能 内部使用dependencyTasks
            __block BOOL dependenciesCompleted = YES;
            [task.dependencyTasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull dependencyTask, NSUInteger idx, BOOL * _Nonnull stop) {
                if (dependencyTask.status != MJKTaskStatusCompleted) {
                    *stop = YES;
                    dependenciesCompleted = NO;
                    return;
                }
            }];
            
            if (!dependenciesCompleted) {
                return;
            }
            
            MJKTaskPriority executingTasksMaxPriority = [self findMaxPriorityForTasks:self.executingTasks];
            if (task.priority < executingTasksMaxPriority) {
                *stop = YES;
                return;
            }
            
            [task setStatus:MJKTaskStatusExecuting];
            [self.executingTasks addObject:task];
            [willExecuteTasks addObject:task];
        }];
        
        if ([willExecuteTasks count] > 0) {
            [self.tasks removeObjectsInArray:willExecuteTasks];
        }
    }];
    
    if ([willExecuteTasks count] <= 0) {
        return;
    }
    
    [willExecuteTasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [self executeTask:task];
    }];
}

- (void)executeTask:(MJKTask *)task {
    void (^block)(void) = ^{
        task.taskBlock(^{
            [task tryCompleted];
        });
    };
    
    if (!task.isInMainThread) {
        [self.operationQueue addOperationWithBlock:block];
    } else {
        if ([NSThread isMainThread]) {
            block ? block() : nil;
        } else {
            dispatch_async(dispatch_get_main_queue(), block);
        }
    }
}

- (MJKTaskPriority)findMaxPriorityForTasks:(NSArray<MJKTask *> *)tasks {
    __block MJKTaskPriority priority = MJKTaskPriorityLow;
    [tasks enumerateObjectsUsingBlock:^(MJKTask * _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if (task.priority > priority) {
            priority = task.priority;
        }
    }];
    
    return priority;
}

@end
