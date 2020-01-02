//
//  MJKHighPriorityTasksStage.m
//  MJKScheduler
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "MJKHighPriorityTasksStage.h"

@implementation MJKHighPriorityTasksStage

- (void)execute {
    MJKTask *highPriorityTask1 = [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        sleep(2);
        NSLog(@"HighPriority1");
        completedCallback ? completedCallback() : nil;
    } priority:MJKTaskPriorityHigh identifier:@"HighPriority1"];
    
    MJKTask *highPriorityTask2 = [[MJKTask alloc] initWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        NSLog(@"HighPriority2");
        completedCallback ? completedCallback() : nil;
    } priority:MJKTaskPriorityHigh identifier:@"HighPriority2"];
    [highPriorityTask2 addDependencyTask:highPriorityTask1];
    [self.taskQueue addTask:highPriorityTask2];
    
    
    MJKTask *highPriorityTask3 = [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        NSLog(@"HighPriority3");
        completedCallback ? completedCallback() : nil;
    } priority:MJKTaskPriorityHigh identifier:@"HighPriority3"];
    
    __weak typeof(self) weakSelf = self;
    MJKTask *compeletedTask = [[MJKTask alloc] initWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        NSLog(@"HighPriorityCompeletedTask");
        completedCallback ? completedCallback() : nil;
        weakSelf.completedCallBlock ? weakSelf.completedCallBlock() : nil;
    } priority:MJKTaskPriorityHigh identifier:@"HighPriorityCompeletedTask"];
    [compeletedTask addDependencyTasks:@[highPriorityTask2, highPriorityTask3]];
    
    [self.taskQueue addTask:compeletedTask];
}


@end
