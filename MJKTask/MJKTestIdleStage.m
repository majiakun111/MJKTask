//
//  MJKTestIdleStage.m
//  MJKScheduler
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import "MJKTestIdleStage.h"

@implementation MJKTestIdleStage

- (void)execute {
    [super execute];
    
    [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
           sleep(2);
           NSLog(@"IdleStage1");
           completedCallback ? completedCallback() : nil;
    } priority:MJKTaskPriorityHigh identifier:@"IdleStage1"];
    
    __weak typeof(self) weakSelf = self;
    [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        sleep(3);
        NSLog(@"idleStage2");
        completedCallback ? completedCallback() : nil;
        weakSelf.completedCallBlock ? weakSelf.completedCallBlock() : nil;
     } priority:MJKTaskPriorityHigh identifier:@"idleStage2"];
}

@end
