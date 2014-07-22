//
//  MADial.m
//  MADial
//
//  Created by Mike on 7/20/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import "MADial.h"

static NSInteger const kMADefaultMaxValue = 100;
static NSInteger const kMADefaultMinValue = 0;

static CGFloat const kMADefaultRingWidth = 4.0;
static CGFloat const kMADefaultHandleWidth = 12.0;

static NSString * const kMADefaultFont = @"HelveticaNeue-Light";

const CGFloat kMAInset = 15.0f;
const CGFloat kMALabelSize = 40;
const CGFloat kMASpringVelocity = 20.0;
const CGFloat kMADamping = 0.8;
const CGFloat kMAAnimationDuration = 0.1;

@interface MADial ()
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint timerCenter;
@property (nonatomic, assign) CGFloat currentValue;
@property (nonatomic, assign) CGFloat dialRadius;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGRect timerElementsRect;
@property (nonatomic, assign) CGRect staticLabelRect;
@property (nonatomic, assign) CGRect valueLabelRect;
@property (nonatomic, strong) CAShapeLayer *majorShapeLayer;
@property (nonatomic, strong) CAShapeLayer *minorShapeLayer;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic) BOOL showHandle;
@end

@implementation MADial

+ (instancetype)dialWithInitialValue:(NSInteger)initialValue min:(NSInteger)min max:(NSInteger)max unit:(NSString *)unit valueChangedHandler:(void (^)(NSInteger updatedValue))handler {
    MADial *dial = [MADial new];
    dial.minValue = min;
    dial.maxValue = max;
    dial.valueLabel.text = [NSString stringWithFormat:@"%@", @(initialValue)];
    dial.unitLabel.text = unit;
    dial.valueChangedHandler = handler ?: ^void(NSInteger unusedInteger){};
    return dial;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    
    // the default for everything will be black unless otherwise specified
    UIColor *defaultColor = [UIColor blackColor];
    self.dialColor = defaultColor;
    self.valueLabelColor = defaultColor;
    self.unitLabelColor = defaultColor;
    self.maskViewColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    
    // set the deafult min and max values
    self.minValue = kMADefaultMinValue;
    self.maxValue = kMADefaultMaxValue;
    
    // create the value label
    self.valueLabel = [UILabel new];
    self.valueLabel.adjustsFontSizeToFitWidth = YES;
    self.valueLabel.layer.cornerRadius = 10.0f;
    self.valueLabel.clipsToBounds = YES;
    self.valueLabel.textColor = defaultColor;
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.valueLabel];
    
    // create the unit label
    self.unitLabel = [UILabel new];
    self.unitLabel.adjustsFontSizeToFitWidth = YES;
    self.unitLabel.textAlignment = NSTextAlignmentCenter;
    self.unitLabel.textColor = defaultColor;
    [self addSubview:self.unitLabel];
    
    // create our shape layers
    self.minorShapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.minorShapeLayer];
    
    self.majorShapeLayer = [CAShapeLayer layer];
    [self.layer addSublayer:self.majorShapeLayer];
    
    // default handler in case one isn't provided we won't crash
    self.valueChangedHandler = ^void(NSInteger unusedInteger){};
    
    // bring the value label to the front so when we animate it around
    // later it's on top of everything else
    [self bringSubviewToFront:self.valueLabel];
    
    // if user interaction is enabled, show the handle
    self.showHandle = self.userInteractionEnabled;
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // if we have set a universal color, set everything to that
    if (self.color) {
        self.unitLabelColor = self.color;
        self.valueLabelColor = self.color;
        self.dialColor = self.color;
    }
    
    // here we want to grab a reference to our frame now that we have one
    // and do anything that requires it
    CGRect frame = self.frame;
    CGRect bounds = self.bounds;
    
    // this is the rect that will encompass all of the components and is
    // simply a rect with the same proportions as the view itself with a
    // default inset value
    _timerElementsRect = CGRectInset(frame, kMAInset, kMAInset);
    
    // the radius of the dial is going to be half of the width of
    // the timer element itself
    _dialRadius = CGRectGetWidth(_timerElementsRect) / 2;
    
    // the static label is a reference to the center point for the value label
    // as it normally sits, so when we move it out of the way of touches later
    // on we have some original rect to reference to move it back.
    _staticLabelRect = CGRectInset(bounds, kMAInset + floorf(0.2 * frame.size.width), kMAInset + floorf(0.2 * frame.size.height));
    _staticLabelRect.origin.y -= floorf(0.1 * frame.size.height);
    
    // now that we have the rect for the static label, lets point the value label
    // to it so it is correctly situated at the start
    _valueLabelRect = _staticLabelRect;
    _valueLabel.frame = _valueLabelRect;
    
    
    _unitLabel.frame = CGRectMake(CGRectGetMinX(_staticLabelRect), CGRectGetMaxY(_staticLabelRect)-floorf(0.1 * CGRectGetHeight(_valueLabelRect)), _valueLabelRect.size.width, floorf(0.5f * CGRectGetHeight(_valueLabelRect)));
    _unitLabel.textColor = _unitLabelColor;
    
    // set the font size based on the height of the label
    self.fontSize = ceilf(0.85f * CGRectGetHeight(_valueLabelRect));
    _unitLabel.font = [UIFont fontWithName:kMADefaultFont size:floorf(self.fontSize/2.0f)];
}

- (void)drawRect:(CGRect)rect {
    CGFloat startAngle = 3 * M_PI / 2;
    _endAngle = [self.valueLabel.text integerValue] * 2 * M_PI / self.maxValue - M_PI_2;
    _timerCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    UIColor *timerColor = self.dialColor;
    [timerColor setFill];
    
    UIBezierPath *timerPath = UIBezierPath.bezierPath;
    [timerPath addArcWithCenter:_timerCenter radius:_dialRadius startAngle:startAngle endAngle:startAngle - 0.01 clockwise:YES];
    
    _majorShapeLayer.fillColor = [[UIColor clearColor] CGColor];
    _majorShapeLayer.strokeColor = [timerColor CGColor];
    _majorShapeLayer.lineWidth = kMADefaultRingWidth;
    _majorShapeLayer.strokeEnd = (float)[self.valueLabel.text integerValue] / self.maxValue;
    _majorShapeLayer.path = timerPath.CGPath;
    
    // if user interaction is enabled on this view, add the handle (little dot) to the end of
    // the path with the default radius, otherwise use a smaller radius so it appears less likely
    // to be able to be interacted with
    CGFloat handleRadius = self.userInteractionEnabled ? kMADefaultHandleWidth : 0;
    UIBezierPath *handlePath = [UIBezierPath bezierPathWithArcCenter:[self currentPointAlongDial] radius:handleRadius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [handlePath fill];
    
    [self resetValueLabel];
}

- (void)resetValueLabel {
    self.valueLabel.textColor = _valueLabelColor;
    self.valueLabel.font = [UIFont fontWithName:kMADefaultFont size:self.fontSize];
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


#pragma mark - helper methods

- (CGPoint)currentPointAlongDial {
    CGFloat endAngle = [self.valueLabel.text integerValue] * 2 * M_PI / self.maxValue - M_PI_2;
    CGFloat handleAngle = endAngle + M_PI_2;
    CGPoint handlePoint = CGPointZero;
    handlePoint.x = self.timerCenter.x + (self.dialRadius) * sinf(handleAngle);
    handlePoint.y = self.timerCenter.y - (self.dialRadius) * cosf(handleAngle);
    return handlePoint;
}


#pragma mark - Handling touch events

- (void)animateValueLabelToNewPosition {
    // this was originally called in the completion handler of the animation block,
    // but that was causing timing issues in some cases where the completion block
    // of this function was executed after the beginning of the 'animateValueLabelBack'
    // function, resulting in the background being
    self.valueLabel.backgroundColor = self.maskViewColor;
    
    // animate the value label to a point centered above where the finger tapped along
    // the dial itself and when done redraw everything
    CGPoint handlePoint = [self currentPointAlongDial];
    [UIView animateWithDuration:kMAAnimationDuration delay:0 usingSpringWithDamping:kMADamping initialSpringVelocity:kMASpringVelocity options:kNilOptions animations:^{
        self.valueLabel.center = CGPointMake(handlePoint.x, handlePoint.y - self.staticLabelRect.size.height / 2 - 40);
    } completion:^(BOOL finished) {
        [self setNeedsDisplay];
    }];
}

- (void)animateValueLabelBack {
    // change the background color back to clear
    self.valueLabel.backgroundColor = [UIColor clearColor];
    
    // animate the value label back to the reference label and
    // when it's done redraw everything
    [UIView animateWithDuration:kMAAnimationDuration animations:^{
        self.valueLabel.frame = self.staticLabelRect;
    } completion:^(BOOL finished) {
        [self setNeedsDisplay];
    }];
}

- (void)handleTouch:(UITouch *)touch {
    // get the position of the touch in the view
    CGPoint position = [touch locationInView:self];
    
    // calculate the angle of the touch from the center of the timer
    CGFloat angleInDegrees = atanf((position.y - self.timerCenter.y) / (position.x - self.timerCenter.x)) * 180 / M_PI + 90;
    
    // the angle calculation doesn't tell us which direction it's in,
    // so if the position of the touch is to the left of center, we
    // want to offset the actual angle 180 degrees so its on the
    // correct side
    if (position.x < self.timerCenter.x) {
        angleInDegrees += 180;
    }
    
    // calculate the selected time on the timer itself based on this angle and set it
    // as the current time
    NSInteger newTime = (NSInteger)(angleInDegrees * self.maxValue / 360);
    [self updateValue:newTime];
    
    // now animate the value label to the correct position so the user's
    // finger doesn't cover it up
    [self animateValueLabelToNewPosition];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // pass the touch even to the function that handles it
    UITouch *touch = [[event touchesForView:self] anyObject];
    [self handleTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // pass the touch even to the function that handles it
    UITouch *touch = [[event touchesForView:self] anyObject];
    [self handleTouch:touch];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // get the value from the label now that the user has stopped moving the
    // dial, and pass it back to our handler
    self.valueChangedHandler([self.valueLabel.text integerValue]);
    
    // now that the touch events ended, we can animate the value
    // label back to the origin
    [self animateValueLabelBack];
}

@end
