//
//  ZGCountDownTimer.m
//  ZGCountDownTimer
//
//  Created by Kyle Fang on 2/28/13.
//  Copyright (c) 2013 Kyle Fang. All rights reserved.
//

#import "ZGCountDownTimer.h"

#define kZGCountDownTimerCompleteDateKey    @"countDownCompleteDate"
#define kZGCountDownTimerTimePassedKey      @"countDownTimePassed"
#define kZGCountDownTotalTimeKey            @"countDownTotalTime"
#define kZGCountDownRunningKey              @"countDownRunning"

@interface ZGCountDownTimer()

@property (nonatomic) NSTimer *defaultTimer;
@property (nonatomic) NSTimeInterval timePassed;
@property (nonatomic) BOOL countDownRuning;
@property (nonatomic) NSDate *countDownCompleteDate;
@end

@implementation ZGCountDownTimer

- (id)init{
    self = [super init];
    if (self) {
        self.timePassed = 0;
        self.totalCountDownTime = 0;
        self.countDownRuning = NO;
    }
    return self;
}

- (NSTimer *)defaultTimer{
    if (!_defaultTimer) {
    }
    return _defaultTimer;
}

- (BOOL)isRunning{
    return self.countDownRuning;
}

- (BOOL)started{
    return self.timePassed>0;
}

- (void)timerUpdated:(NSTimer *)timer{
    NSLog(@"update");
    if (self.countDownRuning) {
        if ([self.countDownCompleteDate timeIntervalSinceNow]<0) {
            if ([self.delegate respondsToSelector:@selector(countDownCompleted:)]) {
                [self.delegate countDownCompleted:self];
            }
            [self resetCountDown];
        } else {
            NSTimeInterval newTimePassed = round(self.totalCountDownTime - [self.countDownCompleteDate timeIntervalSinceNow]);
            if ([self.delegate respondsToSelector:@selector(secondUpdated:countDownTimePassed:ofTotalTime:)]) {
                [self.delegate secondUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
            }
            if ((int)round(self.timePassed)%60 == 0 || newTimePassed-self.timePassed > 60) {
                if ([self.delegate respondsToSelector:@selector(minutesUpdated:countDownTimePassed:ofTotalTime:)]) {
                    [self.delegate minutesUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
                }
            }
            if ((int)round(self.timePassed)%(60*60) == 0 || newTimePassed - self.timePassed > 60*60) {
                if ([self.delegate respondsToSelector:@selector(hoursUpdated:countDownTimePassed:ofTotalTime:)]) {
                    [self.delegate hoursUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
                }
            }
            self.timePassed = newTimePassed;
        }
    }
}

- (BOOL )startCountDown{
    if (self.totalCountDownTime > self.timePassed && !self.countDownRuning) {
        self.countDownCompleteDate = [NSDate dateWithTimeInterval:(self.totalCountDownTime - self.timePassed) sinceDate:[NSDate date]];
        self.countDownRuning = YES;
        if (!self.defaultTimer) {
            self.defaultTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
            [self.defaultTimer fire];
            [[NSRunLoop currentRunLoop] addTimer:self.defaultTimer forMode:NSDefaultRunLoopMode];
            NSLog(@"Timer fired");
        }
        return YES;
    } else {
        return NO;
    }
}

- (BOOL )pauseCountDown{
    if (self.totalCountDownTime > self.timePassed && self.countDownRuning) {
        self.countDownRuning = NO;
        return YES;
    } else {
        return NO;
    }
}

- (void)resetCountDown{
    [self pauseCountDown];
    [self.delegate countDownCompleted:self];
    self.timePassed = 0;
}

- (NSString *)getDateStringForTimeInterval:(NSTimeInterval)timeInterval{
    return [self getDateStringForTimeInterval:timeInterval withDateFormatter:nil];
}

- (NSString *)getDateStringForTimeInterval:(NSTimeInterval )timeInterval withDateFormatter:(NSNumberFormatter *)formatter{
    double hours;
    double minutes;
    double seconds = round(timeInterval);
    hours = floor(seconds / 3600.);
    seconds -= 3600. * hours;
    minutes = floor(seconds / 60.);
    seconds -= 60. * minutes;
    
    if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMaximumFractionDigits:1];
        [formatter setPositiveFormat:@"#00"];  // Use @"#00.0" to display milliseconds as decimal value.
    }
    
    NSString *secondsInString = [formatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
    
    if (hours == 0) {
        return [NSString stringWithFormat:NSLocalizedString(@"%02.0f:%@", @"Short format for elapsed time (minute:second). Example: 05:3.4"), minutes, secondsInString];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"%.0f:%02.0f:%@", @"Short format for elapsed time (hour:minute:second). Example: 1:05:3.4"), hours, minutes, secondsInString];
    }
}

- (NSDictionary *)countDownInfoForBackup{
    return @{kZGCountDownTimerCompleteDateKey: self.countDownCompleteDate,
             kZGCountDownTimerTimePassedKey: [NSNumber numberWithDouble:self.timePassed],
             kZGCountDownTotalTimeKey: [NSNumber numberWithDouble:self.totalCountDownTime],
             kZGCountDownRunningKey: [NSNumber numberWithBool:self.countDownRuning]};
}

- (void)restoreWithCountDownBackup:(NSDictionary *)countDownInfo{
    self.totalCountDownTime = [[countDownInfo valueForKey:kZGCountDownTotalTimeKey] doubleValue];
    self.timePassed = [[countDownInfo valueForKey:kZGCountDownTimerTimePassedKey] doubleValue];
    self.countDownCompleteDate = [countDownInfo valueForKey:kZGCountDownTimerCompleteDateKey];
    BOOL isRunning = [[countDownInfo valueForKey:kZGCountDownRunningKey] boolValue];
    if (isRunning) {
        [self startCountDown];
    }
}


- (void)dealloc{
    [self.defaultTimer invalidate];
}

@end
