//
//  MJKStageScheduler.h
//  MJKScheduler
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJKStageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//就是Chain
@interface MJKStageChain : NSObject<MJKStageProtocol>

- (instancetype)initWithStageProtocols:(NSArray<id<MJKStageProtocol>> *)stageProtocols;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - MJKStageProtocol
@property(nonatomic, strong) id<MJKStageProtocol> next;
@property(nonatomic, copy) void(^completedCallBlock)(void) NS_UNAVAILABLE;
- (void)execute;

@end

NS_ASSUME_NONNULL_END
