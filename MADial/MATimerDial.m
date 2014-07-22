//
//  MATimerDial.m
//  MADial
//
//  Created by Mike on 7/20/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import "MATimerDial.h"

static NSString * const kMAMinuteLabelText = @"min";
static NSString * const kMASecondLabelText = @"sec";

static NSInteger const kMADefaultMaxValue = 60;

@interface MATimerDial ()
@property (nonatomic, strong) NSTimer *updateTimer;
@end

@implementation MATimerDial

+ (instancetype)timerControlWithInterval:(MATimerDialInterval)interval direction:(MATimerDialDirection)direction startValue:(NSInteger)startValue {
    MATimerDial *timerDial = [MATimerDial new];
    timerDial.timeInterval = interval;
    timerDial.direction = direction;
    
    if (interval == MATimerDialIntervalSeconds) {
        NSInteger actualStartValue = startValue >= kMADefaultMaxValue ? kMADefaultMaxValue : startValue;
        timerDial.valueLabel.text = [NSString stringWithFormat:@"%@", @(actualStartValue)];
        timerDial.unitLabel.text = kMASecondLabelText;
    }
    else {
        timerDial.unitLabel.text = kMAMinuteLabelText;
    }
    return timerDial;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.maxValue = kMADefaultMaxValue;
    self.userInteractionEnabled = NO;
    
    return self;
}

#pragma mark - Starting and stopping

- (void)start {
    // if the timer is not active, create a repeating timer with the appropriate
    // time interval and start it immediately
    if (!self.isActive) {
        self.isActive = YES;
        NSTimeInterval updateInterval = self.timeInterval ==MATimerDialIntervalSeconds ? 1 : 60;
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

- (void)stop {
    // if the timer is active, flag we're no longer active, stop the timer
    // from firing in the future, and get rid of the reference to it
    if (self.isActive) {
        self.isActive = NO;
        [self.updateTimer invalidate];
        self.updateTimer = nil;
    }
}

- (void)updateTime {
    NSInteger nextMinuteOrSecond;
    NSInteger currentTime = [self.valueLabel.text integerValue];
    
    // if the timer is configured to count up, increment the time unless
    // we need to start it back at zero
    if (self.direction == MATimerDialDirectionUp) {
        nextMinuteOrSecond = currentTime == kMADefaultMaxValue - 1 ? 0 : currentTime + 1;
    }
    
    // otherwise we're configured to count down, so decrement the time unless
    // we need to wrap back around to 59 seconds/mins
    else {
        nextMinuteOrSecond = currentTime == 0 ? kMADefaultMaxValue - 1 : currentTime - 1;
    }
    
    // update our time accordingly
    [self updateValue:nextMinuteOrSecond];
}

- (void)updateValue:(NSInteger)newValue {
    if (newValue > self.maxValue) {
        newValue = self.maxValue;
    } else if (newValue < self.minValue) {
        newValue = self.minValue;
    }
    
    self.valueLabel.text = [NSString stringWithFormat:@"%@", @(newValue)];
    [self setNeedsDisplay];
}

@end
