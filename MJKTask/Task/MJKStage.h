//
//  MJKLaunchStage.h
//  MJKTask
//
//  Created by Ansel on 2019/12/31.
//  Copyright © 2019 Ansel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJKStageProtocol.h"
#import "MJKTaskQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface MJKStage : NSObject<MJKStageProtocol>

@property (nonatomic, strong, readonly) MJKTaskQueue *taskQueue;

#pragma mark - MJKStageProtocol

@property(nonatomic, copy) void(^completedCallBlock)(void);
@property(nonatomic, strong) id<MJKStageProtocol> next;
- (void)execute;

@end

NS_ASSUME_NONNULL_END
