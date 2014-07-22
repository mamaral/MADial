
//
//  MADial.h
//  MADial
//
//  Created by Mike on 7/20/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADial : UIView

@property (nonatomic, assign) NSInteger maxValue;
@property (nonatomic, assign) NSInteger minValue;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *dialColor;
@property (nonatomic, strong) UIColor *valueLabelColor;
@property (nonatomic, strong) UIColor *unitLabelColor;
@property (nonatomic, strong) UIColor *maskViewColor;

@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitLabel;

@property (nonatomic, copy) void (^valueChangedHandler)(NSInteger);

+ (instancetype)dialWithInitialValue:(NSInteger)initialValue min:(NSInteger)min max:(NSInteger)max unit:(NSString *)unit valueChangedHandler:(void (^)(NSInteger updatedValue))handler;

@end