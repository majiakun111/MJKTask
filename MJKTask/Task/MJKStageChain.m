//
//  MJKStageChain.m
//  MJKTask
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import "MJKStageChain.h"

@interface MJKStageChain ()

@property (nonatomic, strong) NSMutableArray<id<MJKStageProtocol>> *stageProtocols;
@property (nonatomic, strong) id<MJKStageProtocol> idleStageProtocol;

@end

@implementation MJKStageChain

- (instancetype)initWithStageProtocols:(NSArray<id<MJKStageProtocol>> *)stageProtocols idleStageProtocol:(id<MJKStageProtocol>)idleStageProtocol {
    self = [super init];
    if (self) {
        self.stageProtocols = @[].mutableCopy;
        self.idleStageProtocol = idleStageProtocol;
        if ([stageProtocols count] > 0) {
            [self.stageProtocols addObjectsFromArray:stageProtocols];
            [self buildStageChainWithStageProtocols:self.stageProtocols];
        }
    }
    
    return self;
}

- (void)addStageProtocol:(id<MJKStageProtocol>)stageProtocol {
    if (!stageProtocol) {
        return;
    }
    
    id<MJKStageProtocol> beforeLastStageProtocol = [self.stageProtocols lastObject];
    if (!beforeLastStageProtocol) {
        self.next = stageProtocol;
    } else {
        beforeLastStageProtocol.next = stageProtocol;
    }
    
    [self configCompletedCallBlockForStageProtocol:stageProtocol];
    
    [self.stageProtocols addObject:stageProtocol];
}

#pragma mark - MJKStageProtocol

- (void)execute {
    [self.next execute];
}

#pragma mark - PrivateMethod

//生成链
- (void)buildStageChainWithStageProtocols:(NSArray<id<MJKStageProtocol>> *)stageProtocols {
    __block id<MJKStageProtocol> cursor = nil;
    [stageProtocols enumerateObjectsUsingBlock:^(id<MJKStageProtocol>  _Nonnull stageProtocol, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!cursor) {
            self.next = stageProtocol;
            cursor = stageProtocol;
        } else {
            cursor.next = stageProtocol;
            cursor = stageProtocol;
        }
        
        [self configCompletedCallBlockForStageProtocol:stageProtocol];
    }];
}

- (void)configCompletedCallBlockForStageProtocol:(id<MJKStageProtocol>)stageProtocol {
    __weak typeof(stageProtocol) weakStageProtocol = stageProtocol;
    [stageProtocol setCompletedCallBlock:^{
        if (weakStageProtocol.next) {
            [weakStageProtocol.next execute];
        } else {
            [self.idleStageProtocol execute];
        }
    }];
}

@end
