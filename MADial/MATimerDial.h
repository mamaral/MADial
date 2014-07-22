//
//  MATimerDial.h
//  MADial
//
//  Created by Mike on 7/20/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import "MADial.h"

typedef NS_ENUM(NSUInteger, MATimerDialDirection) {
    MATimerDialDirectionUp = 0,
    MATimerDialDirectionDown
};

typedef NS_ENUM(NSUInteger, MATimerDialInterval) {
    MATimerDialIntervalSeconds = 0,
    MATimerDialIntervalMinutes
};

@interface MATimerDial : MADial

@property (nonatomic, assign) MATimerDialInterval timeInterval;
@property (nonatomic, assign) MATimerDialDirection direction;

@property (nonatomic) BOOL isActive;

+ (instancetype)timerControlWithInterval:(MATimerDialInterval)interval direction:(MATimerDialDirection)direction startValue:(NSInteger)startValue;

- (void)start;
- (void)stop;

@end
