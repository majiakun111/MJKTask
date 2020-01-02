//
//  ViewController.m
//  MJKScheduler
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "ViewController.h"
#import "MJKStageChain.h"
#import "MJKHighPriorityTasksStage.h"
#import "MJKUITasksStage.h"
#import "MJKTestIdleStage.h"

@interface ViewController ()

@property (nonatomic, strong) MJKStageChain *stageScheduler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    id<MJKStageProtocol> highPriorityTasksStage = [[MJKHighPriorityTasksStage alloc] init];
    id<MJKStageProtocol> UITasksStage = [[MJKUITasksStage alloc] init];
    id<MJKStageProtocol> idleStage = [[MJKTestIdleStage alloc] init];
    self.stageScheduler = [[MJKStageChain alloc] initWithStageProtocols:@[highPriorityTasksStage, UITasksStage, idleStage]];
    [self.stageScheduler execute];
}

@end
