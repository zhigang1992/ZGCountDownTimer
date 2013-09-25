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
@property (nonatomic, strong) ZGCountDownTimer *myCountDownTimer;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.myCountDownTimer = [ZGCountDownTimer countDownTimerWithIdentifier:self.tabBarItem.title];
    
    self.myCountDownTimer.delegate = self;
    [self.myCountDownTimer setupCountDownForTheFirstTime:^(ZGCountDownTimer *timer) {
        timer.totalCountDownTime = kDefaultCountDownTime;
    } restoreFromBackUp:nil];
}

- (void)secondUpdated:(ZGCountDownTimer *)sender countDownTimePassed:(NSTimeInterval)timePassed ofTotalTime:(NSTimeInterval)totalTime
{
    self.atitle.text = [ZGCountDownTimer getDateStringForTimeInterval:(totalTime - timePassed)];
}

- (void)countDownCompleted:(ZGCountDownTimer *)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Completed" message:@"Completed!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
}

- (IBAction)start:(id)sender
{
    [self.myCountDownTimer startCountDown];
}

- (IBAction)pause:(id)sender
{
    [self.myCountDownTimer pauseCountDown];
}

- (IBAction)reset:(id)sender
{
    [self.myCountDownTimer resetCountDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
