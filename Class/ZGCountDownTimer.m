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

#define kZGCountDownUserDefaultKey          @"ZGCountDownUserDefaults"

@interface ZGCountDownTimer ()

@property(nonatomic) NSTimer *defaultTimer;
@property(nonatomic) NSTimeInterval timePassed;
@property(nonatomic) BOOL countDownRunning;
@property(nonatomic) NSDate *countDownCompleteDate;
@end

@implementation ZGCountDownTimer

#pragma mark - init methods
static NSMutableDictionary *_countDownTimersWithIdentifier;

+ (ZGCountDownTimer *)defaultCountDownTimer {
    return [self countDownTimerWithIdentifier:kZGCountDownUserDefaultKey];
}

+ (ZGCountDownTimer *)countDownTimerWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        identifier = kZGCountDownUserDefaultKey;
    }
    if (_countDownTimersWithIdentifier) {
        _countDownTimersWithIdentifier = [[NSMutableDictionary alloc] init];
    }
    ZGCountDownTimer *timer = [_countDownTimersWithIdentifier objectForKey:identifier];
    if (!timer) {
        timer = [[self alloc] init];
        timer.timerIdentifier = identifier;
        [_countDownTimersWithIdentifier setObject:timer forKey:identifier];
    }
    return timer;
}

#pragma mark - setup methods

- (void)setupCountDownForTheFirstTime:(void (^)(ZGCountDownTimer *))firstBlock
                    restoreFromBackUp:(void (^)(ZGCountDownTimer *))restoreFromBackup {

    if ([self backupExist]) {
        [self restoreMySelf];
        if (restoreFromBackup) {
            restoreFromBackup(self);
        }
    }
    else {
        self.totalCountDownTime = 0;
        self.timePassed = 0;
        if (firstBlock) {
            firstBlock(self);
        }
    }
}

#pragma setters
- (void)setTotalCountDownTime:(NSTimeInterval)totalCountDownTime {
    _totalCountDownTime = totalCountDownTime;
    [self notifyDelegate];
}

- (void)setCountDownRunning:(BOOL)countDownRunning {
    _countDownRunning = countDownRunning;

    if (!self.defaultTimer && countDownRunning) {
        [self setupDefaultTimer];
        [self timerUpdated:self.defaultTimer];
    }

    if (!countDownRunning) {
        [self notifyDelegate];
    }
}


#pragma mark - timer API
- (BOOL)isRunning {
    return self.countDownRunning;
}

- (BOOL)started {
    return self.timePassed > 0;
}

- (BOOL)startCountDown {
    BOOL result = NO;
    if (!self.countDownRunning) {
        if (self.totalCountDownTime > self.timePassed) {
            self.countDownCompleteDate = [NSDate dateWithTimeInterval:(self.totalCountDownTime - self.timePassed) sinceDate:[NSDate date]];
            self.countDownRunning = YES;
            [self backUpMySelf];
            result = YES;
        }
        else {
            [self.delegate countDownCompleted:self];
            [self removeBackupOfMyself];
        }
    }
    return result;
}

- (BOOL)pauseCountDown {
    if (self.countDownRunning) {
        self.countDownRunning = NO;
        [self backUpMySelf];
        return YES;
    }
    else {
        return NO;
    }
}

- (void)resetCountDown {
    self.timePassed = 0;
    self.countDownRunning = NO;
    [self removeBackupOfMyself];
}

#pragma mark - timer update method
- (void)timerUpdated:(NSTimer *)timer {
    if (self.countDownRunning) {
        if ([self.countDownCompleteDate timeIntervalSinceNow] <= 0) {
            self.timePassed = MAX(0, round(self.totalCountDownTime - [self.countDownCompleteDate timeIntervalSinceNow]));
            if ([self.delegate respondsToSelector:@selector(countDownCompleted:)]) {
                [self.delegate countDownCompleted:self];
            }
            [self resetCountDown];
        }
        else {
            NSTimeInterval newTimePassed = round(self.totalCountDownTime - [self.countDownCompleteDate timeIntervalSinceNow]);
            [self notifySpecificDelegateMethods:newTimePassed];
            self.timePassed = newTimePassed;
        }
    }
}

#pragma mark - helper methods

- (void)setupDefaultTimer {
    self.defaultTimer = [NSTimer timerWithTimeInterval:1.f target:self selector:@selector(timerUpdated:) userInfo:nil repeats:YES];
    [self.defaultTimer fire];
    [[NSRunLoop currentRunLoop] addTimer:self.defaultTimer forMode:NSDefaultRunLoopMode];
}

- (void)notifyDelegate {
    if ([self.delegate respondsToSelector:@selector(secondUpdated:countDownTimePassed:ofTotalTime:)]) {
        [self.delegate secondUpdated:self countDownTimePassed:self.timePassed ofTotalTime:self.totalCountDownTime];
    }

    if ([self.delegate respondsToSelector:@selector(minutesUpdated:countDownTimePassed:ofTotalTime:)]) {
        [self.delegate minutesUpdated:self countDownTimePassed:self.timePassed ofTotalTime:self.totalCountDownTime];
    }

    if ([self.delegate respondsToSelector:@selector(hoursUpdated:countDownTimePassed:ofTotalTime:)]) {
        [self.delegate hoursUpdated:self countDownTimePassed:self.timePassed ofTotalTime:self.totalCountDownTime];
    }
}

- (void)notifySpecificDelegateMethods:(NSTimeInterval)newTimePassed {
    if ([self.delegate respondsToSelector:@selector(secondUpdated:countDownTimePassed:ofTotalTime:)]) {
        [self.delegate secondUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
    }
    if ((int) round(newTimePassed) % 60 == 0 || newTimePassed - self.timePassed > 60) {
        if ([self.delegate respondsToSelector:@selector(minutesUpdated:countDownTimePassed:ofTotalTime:)]) {
            [self.delegate minutesUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
        }
    }
    if ((int) round(newTimePassed) % (60 * 60) == 0 || newTimePassed - self.timePassed > 60 * 60) {
        if ([self.delegate respondsToSelector:@selector(hoursUpdated:countDownTimePassed:ofTotalTime:)]) {
            [self.delegate hoursUpdated:self countDownTimePassed:newTimePassed ofTotalTime:self.totalCountDownTime];
        }
    }
}

#pragma mark - backup/restore methods

- (BOOL)backupExist {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *timerInfo = [defaults objectForKey:self.timerIdentifier];
    return timerInfo != nil;
}

- (void)backUpMySelf {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self countDownInfoForBackup] forKey:self.timerIdentifier];
    [defaults synchronize];
}

- (void)restoreMySelf {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self restoreWithCountDownBackup:[defaults objectForKey:self.timerIdentifier]];
}

- (void)removeBackupOfMyself {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:self.timerIdentifier];
    [defaults synchronize];
}

- (NSDictionary *)countDownInfoForBackup {
    return @{kZGCountDownTimerCompleteDateKey : self.countDownCompleteDate,
            kZGCountDownTimerTimePassedKey : [NSNumber numberWithDouble:self.timePassed],
            kZGCountDownTotalTimeKey : [NSNumber numberWithDouble:self.totalCountDownTime],
            kZGCountDownRunningKey : [NSNumber numberWithBool:self.countDownRunning]};
}

- (void)restoreWithCountDownBackup:(NSDictionary *)countDownInfo {
    self.totalCountDownTime = [[countDownInfo valueForKey:kZGCountDownTotalTimeKey] doubleValue];
    self.timePassed = [[countDownInfo valueForKey:kZGCountDownTimerTimePassedKey] doubleValue];
    self.countDownCompleteDate = [countDownInfo valueForKey:kZGCountDownTimerCompleteDateKey];
    self.countDownRunning = [[countDownInfo valueForKey:kZGCountDownRunningKey] boolValue];
}


#pragma mark - Dealloc
- (void)dealloc {
    [self.defaultTimer invalidate];
}

#pragma mark - helper on time formatter
+ (NSString *)getDateStringForTimeInterval:(NSTimeInterval)timeInterval {
    return [self getDateStringForTimeInterval:timeInterval withDateFormatter:nil];
}

+ (NSString *)getDateStringForTimeInterval:(NSTimeInterval)timeInterval withDateFormatter:(NSNumberFormatter *)formatter {
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

@end
