//
//  MJKUITasksStage.m
//  MJKTask
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "MJKUITasksStage.h"

@implementation MJKUITasksStage

- (void)execute {
    [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        NSLog(@"UI1");
        completedCallback ? completedCallback() : nil;
    } priority:MJKTaskPriorityNormal identifier:@"UI1" inMainThread:YES];
    
    __weak typeof(self) weakSelf = self;
    [self.taskQueue addTaskWithTaskBlock:^(MJKTaskCompletedCallback  _Nonnull completedCallback) {
        NSLog(@"UI2");
        completedCallback ? completedCallback() : nil;
        weakSelf.completedCallBlock ? weakSelf.completedCallBlock() : nil;
    } priority:MJKTaskPriorityNormal identifier:@"UI2" inMainThread:YES];
}

@end
