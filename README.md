MADial and MATimerDial
==================

MADial and MATimerDial are UIViews that quickly and easily created to add slick circular sliders or minute/second timers to your views.


Usage
=====

Simply drop MADial.h/m and MATimerDial.h/m into your project and you're ready to go!

```js
MATimerDial *timerDial = [MATimerDial timerControlWithInterval:MATimerDialIntervalSeconds direction:MATimerDialDirectionUp startValue:55];
[timerDial start];

MADial *demoDial = [MADial dialWithInitialValue:15 min:0 max:100 unit:@"\u00B0C" valueChangedHandler:^(NSInteger updatedValue) {
    // here you can do whatever you like when the dial's value is changed
}];

// customize the color, set the frame, add it as a subview, etc...
```

![demo](Screenshots/dial_demo.gif)


License & Attribution
=====

This project is made available under the MIT license, as was the original project that was forked from Dominik Hauser's DDHTimerControl (https://github.com/dasdom/DDHTimerControl.)