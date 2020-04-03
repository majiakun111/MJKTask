//
//  ViewController.m
//  MJKTask
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import "ViewController.h"
#import "MJKStageScheduler.h"
#import "MJKHighPriorityTasksStage.h"
#import "MJKUITasksStage.h"
#import "MJKTestIdleStage.h"

@interface ViewController ()

@property (nonatomic, strong) MJKStageScheduler *stageScheduler;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    id<MJKStageProtocol> highPriorityTasksStage = [[MJKHighPriorityTasksStage alloc] init];
    id<MJKStageProtocol> UITasksStage = [[MJKUITasksStage alloc] init];
    id<MJKStageProtocol> idleStage = [[MJKTestIdleStage alloc] init];
    self.stageScheduler = [[MJKStageScheduler alloc] initWithStageProtocols:@[highPriorityTasksStage, UITasksStage] idleStageProtocol:idleStage];
    [self.stageScheduler execute];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touchesEnded -->start");
    sleep(10);
    NSLog(@"touchesEnded -->end");
}

@end
