//
//  MADialDemoViewController.m
//  MADial
//
//  Created by Mike on 7/20/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import "MADialDemoViewController.h"
#import "MADial.h"
#import "MATimerDial.h"

@interface MADialDemoViewController ()

@end

@implementation MADialDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:26/255.0 green:26/255.0 blue:26/255.0 alpha:1.0];
    
    // create a timer dial - give it a type, direction, and an initial value, then later tell it to start
    MATimerDial *timerDial = [MATimerDial timerControlWithInterval:MATimerDialIntervalSeconds direction:MATimerDialDirectionUp startValue:55];
    timerDial.color = [UIColor colorWithRed:220/255.0 green:94/255.0 blue:83/255.0 alpha:1.0];
    timerDial.frame = CGRectMake(70, 20, CGRectGetWidth(self.view.frame) - 140, CGRectGetWidth(self.view.frame) - 140);
    [self.view addSubview:timerDial];
    
    [timerDial start];
    
    // create the dial - start it at some arbitrary value, set the range and unit, and create a block
    // to handle when the value is updated by the user - in this case simply log the result
    MADial *demoDial = [MADial dialWithInitialValue:15 min:0 max:100 unit:@"\u00B0C" valueChangedHandler:^(NSInteger updatedValue) {
        NSLog(@"Dial Value updated to: %@", @(updatedValue));
    }];
    demoDial.color = [UIColor colorWithRed:82/255.0 green:162/255.0 blue:13/255.0 alpha:1.0];;
    demoDial.frame = CGRectMake(40, 230, CGRectGetWidth(self.view.frame) - 80, CGRectGetWidth(self.view.frame) - 80);
    [self.view addSubview:demoDial];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

@end
