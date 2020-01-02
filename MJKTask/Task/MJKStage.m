//
//  MJKLaunchStage.m
//  MJKScheduler
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "MJKStage.h"

@interface MJKStage ()

@property (nonatomic, strong) MJKTaskQueue *taskQueue;

@end

@implementation MJKStage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.taskQueue = [[MJKTaskQueue alloc] init];
    }
    
    return self;
}

#pragma mark - MJKStageProtocol

- (void)execute {
    
}

@end
