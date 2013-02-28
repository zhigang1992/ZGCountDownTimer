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

@interface ViewController () <ZGCountDownTimerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *atitle;
@property (nonatomic) ZGCountDownTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.timer = [[ZGCountDownTimer alloc] init];
    self.timer.delegate = self;
    [self.timer setupCountDownForTheFirstTime:^(ZGCountDownTimer *timer) {
        self.timer.totalCountDownTime = kDefaultCountDownTime;
    } restoreFromBackUp:nil];    
}

- (void)secondUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval)timePassed ofTotalTime:(NSTimeInterval)totalTime{
    self.atitle.text = [sender getDateStringForTimeInterval:(totalTime - timePassed)];
}

- (void)countDownCompleted:(ZGCountDownTimer *)sender{
    self.atitle.text = [self.timer getDateStringForTimeInterval:kDefaultCountDownTime];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Completed" message:@"Completed!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
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
