//
//  MJKStageProtocol.h
//  MJKTask
//
//  Created by Ansel on 2020/1/2.
//  Copyright © 2020 Ansel. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MJKStageProtocol <NSObject>

@required
@property(nonatomic, strong) id<MJKStageProtocol> next;
@property(nonatomic, copy) void(^completedCallBlock)(void);
- (void)execute;

@end

NS_ASSUME_NONNULL_END
