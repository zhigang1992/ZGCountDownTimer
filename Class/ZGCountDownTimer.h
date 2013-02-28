//
//  ZGCountDownTimer.h
//  ZGCountDownTimer
//
//  Created by Kyle Fang on 2/28/13.
//  Copyright (c) 2013 Kyle Fang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class ZGCountDownTimer;

@protocol ZGCountDownTimerDelegate <NSObject>


@optional

- (void)secondUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval )timePassed ofTotalTime:(NSTimeInterval )totalTime;
- (void)minutesUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval )timePassed ofTotalTime:(NSTimeInterval )totalTime;
- (void)hoursUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval )timePassed ofTotalTime:(NSTimeInterval )totalTime;

- (void)countDownCompleted:(ZGCountDownTimer *)sender;

@end


@interface ZGCountDownTimer : NSObject

+ (ZGCountDownTimer *)sharedTimer;

- (void)setupCountDownForTheFirstTime:(void (^)(ZGCountDownTimer *timer))firstBlock restoreFromBackUp:(void (^)(ZGCountDownTimer *timer))restoreFromBackup;

@property (nonatomic) NSTimeInterval totalCountDownTime;

- (BOOL )startCountDown;
- (BOOL )pauseCountDown;
- (void)resetCountDown;

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) BOOL started;

- (NSString *)getDateStringForTimeInterval:(NSTimeInterval )timeInterval;
- (NSString *)getDateStringForTimeInterval:(NSTimeInterval )timeInterval withDateFormatter:(NSNumberFormatter *)dateFormatter;


@property (nonatomic) id <ZGCountDownTimerDelegate> delegate;

@end
