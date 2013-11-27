//
//  ViewController.m
//  ZGCountDownTimer
//
//  Created by Kyle Fang on 2/28/13.
//  Copyright (c) 2013 Kyle Fang. All rights reserved.
//

#import "ViewController.h"
#import "ZGCountDownTimer.h"


#define kDefaultCountDownTime 10
#define kDefaultCountDownNotificationKey @"countDownNotificationKey"

@interface ViewController () <ZGCountDownTimerDelegate>
@property(weak, nonatomic) IBOutlet UILabel *titleLabel;
@property(weak, nonatomic) IBOutlet UILabel *atitle;
@property(nonatomic, strong) ZGCountDownTimer *myCountDownTimer;
@property(nonatomic, strong) UILocalNotification *localNotification;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.titleLabel.text = self.tabBarItem.title;

    self.myCountDownTimer = [ZGCountDownTimer countDownTimerWithIdentifier:self.tabBarItem.title];

    self.myCountDownTimer.delegate = self;
    [self.myCountDownTimer setupCountDownForTheFirstTime:^(ZGCountDownTimer *timer) {
        timer.totalCountDownTime = kDefaultCountDownTime;
    }                                  restoreFromBackUp:^(ZGCountDownTimer *timer) {
        if (!timer.isRunning) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"It's not running anymore"
                                                                message:[NSString stringWithFormat:@"%@ Completed!", self.tabBarItem.title]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Dismiss"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

- (UILocalNotification *)localNotification {
    if (!_localNotification) {
        NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
        for (UILocalNotification *noti in localNotifications) {
            NSString *identifier = [noti.userInfo valueForKey:kDefaultCountDownNotificationKey];
            if ([identifier isEqualToString:self.tabBarItem.title]) {
                _localNotification = noti;
                return _localNotification;
            }
        }
        _localNotification = [[UILocalNotification alloc] init];
        _localNotification.userInfo = @{kDefaultCountDownNotificationKey : self.tabBarItem.title};
        _localNotification.alertBody = [NSString stringWithFormat:@"%@ Completed!", self.tabBarItem.title];
        _localNotification.soundName = UILocalNotificationDefaultSoundName;
    }
    return _localNotification;
}

- (void)secondUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval)timePassed ofTotalTime:(NSTimeInterval)totalTime {
    self.atitle.text = [ZGCountDownTimer getDateStringForTimeInterval:(totalTime - timePassed)];
}

- (void)countDownCompleted:(ZGCountDownTimer *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Completed"
                                                        message:[NSString stringWithFormat:@"%@ Completed!", self.tabBarItem.title]
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)start:(id)sender {
    [self.myCountDownTimer startCountDown];
    self.localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:(self.myCountDownTimer.totalCountDownTime - self.myCountDownTimer.timePassed)];
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
}

- (IBAction)pause:(id)sender {
    [self.myCountDownTimer pauseCountDown];
    [[UIApplication sharedApplication] cancelLocalNotification:self.localNotification];
}

- (IBAction)reset:(id)sender {
    [self.myCountDownTimer resetCountDown];
    [[UIApplication sharedApplication] cancelLocalNotification:self.localNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
