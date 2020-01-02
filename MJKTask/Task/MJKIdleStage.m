//
//  MJKIdleStage.m
//  MJKTask
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import "MJKIdleStage.h"

@interface MJKIdleStage ()

@property (nonatomic, assign) CFRunLoopObserverRef observer;

@end

@implementation MJKIdleStage

- (instancetype)init {
    self = [super init];
    if (self) {
        [self.taskQueue setMaxConcurrentOperationCount:1];
        [self.taskQueue setSuspend:YES];
    }
    
    return self;
}

- (void)execute {
    [super execute];
    
    __weak typeof(self) weakSelf = self;
    
    void(^tmpcompletedCallBlock)(void) = self.completedCallBlock;
    [self setCompletedCallBlock:^{
        tmpcompletedCallBlock ? tmpcompletedCallBlock() : nil;
        [weakSelf stopMonitoringMainThread];
    }];
    [self startMonitorMainThread];
}

#pragma mark - PrivateMethod

- (void)startMonitorMainThread {
    if (self.observer) {
        return;
    }
    
    self.observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                       kCFRunLoopAllActivities,
                                                       YES,
                                                       0,
                                                       ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (activity == kCFRunLoopBeforeWaiting) {
            [self.taskQueue setSuspend:NO];
        } else if (activity == kCFRunLoopBeforeSources ||
                   activity == kCFRunLoopAfterWaiting) {
            [self.taskQueue setSuspend:YES];
        }
    });
    
    CFRunLoopAddObserver(CFRunLoopGetMain(), self.observer, kCFRunLoopCommonModes);
}

- (void)stopMonitoringMainThread {
    if (!self.observer) {
        return;
    }
    
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), self.observer, kCFRunLoopCommonModes);
    CFRelease(self.observer);
    self.observer = nil;
}


@end
