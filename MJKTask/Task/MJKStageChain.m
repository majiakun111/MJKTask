//
//  MJKStageScheduler.m
//  MJKScheduler
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import "MJKStageChain.h"

@interface MJKStageChain ()

@property (nonatomic, strong) NSArray<id<MJKStageProtocol>> *stageProtocols;

@end

@implementation MJKStageChain

- (instancetype)initWithStageProtocols:(NSArray<id<MJKStageProtocol>> *)stageProtocols {
    self = [super init];
    if (self) {
        self.stageProtocols = stageProtocols;
        [self handleNextWithStageProtocols:self.stageProtocols];
    }
    
    return self;
}

#pragma mark - MJKStageProtocol

- (void)execute {
    [self.next execute];
}

#pragma mark - PrivateMethod

//生成链
- (void)handleNextWithStageProtocols:(NSArray<id<MJKStageProtocol>> *)stageProtocols {
    __block id<MJKStageProtocol> cursor = nil;
    [stageProtocols enumerateObjectsUsingBlock:^(id<MJKStageProtocol>  _Nonnull stageProtocol, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!cursor) {
            self.next = stageProtocol;
            cursor = stageProtocol;
        } else {
            cursor.next = stageProtocol;
            cursor = stageProtocol;
        }
        
        __weak typeof(stageProtocol) weakStageProtocol = stageProtocol;
        [stageProtocol setCompletedCallBlock:^{
            [weakStageProtocol.next execute];
        }];
    }];
}


@end
