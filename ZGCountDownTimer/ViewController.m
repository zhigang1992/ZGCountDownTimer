//
//  ViewController.m
//  ZGCountDownTimer
//
//  Created by Kyle Fang on 2/28/13.
//  Copyright (c) 2013 Kyle Fang. All rights reserved.
//

#import "ViewController.h"
#import "ZGCountDownTimer.h"


#define kDefaultCountDownTime 60*60*1

@interface ViewController () <ZGCountDownTimerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *atitle;
@property (nonatomic) ZGCountDownTimer *timer;
@end

@implementation ViewController

- (ZGCountDownTimer *)timer{
    if (!_timer) {
        _timer = [[ZGCountDownTimer alloc] init];
        self.timer.delegate = self;
    }
    return _timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *timerInfo = [defaults objectForKey:@"TimerBackUp"];
    if (timerInfo) {
        [self.timer restoreWithCountDownBackup:timerInfo];
    } else {
        self.atitle.text = [self.timer getDateStringForTimeInterval:kDefaultCountDownTime];
        self.timer.totalCountDownTime = kDefaultCountDownTime;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appQuitting) name:@"MayDay_AppIsQuitting_ThisIsAppDelegate_Copy?" object:nil];
}



- (void)secondUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval)timePassed ofTotalTime:(NSTimeInterval)totalTime{
    self.atitle.text = [sender getDateStringForTimeInterval:(totalTime - timePassed)];
}

- (void)countDownCompleted:(ZGCountDownTimer *)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"TimerBackUp"];
    [defaults synchronize];
}



- (void)appQuitting{
    NSLog(@"BackUp");
    if ([self.timer isRunning] || [self.timer started]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[self.timer countDownInfoForBackup] forKey:@"TimerBackUp"];
        [defaults synchronize];
    }
}

- (IBAction)start:(id)sender {
    [self.timer startCountDown];
}

- (IBAction)pause:(id)sender {
    [self.timer pauseCountDown];
}

- (IBAction)reset:(id)sender {
    [self.timer resetCountDown];
    self.atitle.text = [self.timer getDateStringForTimeInterval:kDefaultCountDownTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
