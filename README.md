ZGCountDownTimer
================

 Background Proof, Termination Proof Timer, Reboot Proof Timer.


[ZGCountDownTimer][] is powered by `NSTimer` to work as a full CountDown Timer.

The best thing about [ZGCountDownTimer][] is that it work acrross **Background App**, **Background Termination** and even **Device Rebbot**.


###Usage

If you want it to work across **Background App**, **Background Termination** and even **Device Rebbot**.
You need to call these two method:

```
// To get a timer.
+ (ZGCountDownTimer *)countDownTimerWithIdentifier:(NSString *)identifier;

// Start using the timer.
- (void)setupCountDownForTheFirstTime:(void (^)(ZGCountDownTimer *timer))firstBlock restoreFromBackUp:(void (^)(ZGCountDownTimer *timer))restoreFromBackup;
```

else it would be just a regular stopWatch the only work across **Background App**.


Control the CountDown timer is as easy as it say:

```
- (BOOL)startCountDown;
- (BOOL)pauseCountDown;
- (void)resetCountDown;
```

Also, there is two help method to help you get the awesome `NSString` with or without customize `NSNumberFormatter`.

```
+ (NSString *)getDateStringForTimeInterval:(NSTimeInterval )timeInterval;
+ (NSString *)getDateStringForTimeInterval:(NSTimeInterval )timeInterval withDateFormatter:(NSNumberFormatter *)dateFormatter;
```

For more detail please see the damo app, or read the docs in the .h file.    
Enjoy.

###Contact

[Twitter](http://twitter.com/F_ZG)    
[Email](zhigang1992@gmail.com)    
[AppNet](https://alpha.app.net/zhigang1992)    

###LICENSE (MIT)

Copyright (C) 2012 by Kyle Fang

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




[ZGCountDownTimer]: https://github.com/zhigang1992/ZGCountDownTimer/new/master?readme=1
