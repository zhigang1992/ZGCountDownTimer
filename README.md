ZGCountDownTimer
================

 Background Proof, Termination Proof Timer, Reboot Proof Timer.


[ZGCountDownTimer][] is a `NSObject` Class that powered with `NSTimer` to work as a full CountDown Timer.

The best thing about [ZGCountDownTimer][] is that it work acrross **Background App**, **Background Termination** and even **Device Rebbot**.


###Usage

If you want it to work across **Background App**, **Background Termination** and even **Device Rebbot**.
You need to implement the method:

```
- (void)setupCountDownForTheFirstTime:(void (^)(ZGCountDownTimer *timer))firstBlock restoreFromBackUp:(void (^)(ZGCountDownTimer *timer))restoreFromBackup;
```

else it would be just a regular stopWatch the only work across **Background App**.


![ZGCountDownTimer]: https://github.com/zhigang1992/ZGCountDownTimer/new/master?readme=1
