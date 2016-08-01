//
//  ViewController.m
//  ZLAudioSmaple
//
//  Created by hitao on 16/8/1.
//  Copyright © 2016年 zwin. All rights reserved.
//

#import "ViewController.h"
#import "ZLAudio.h"

@interface ViewController ()
{
    NSString *fp;
    NSTimer *_timer;
}
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setVoiceImage{
    double voiceSound = [[ZLAudioDeviceManager sharedInstance] peekRecorderVoiceMeter];
    _tipsLabel.text = [NSString stringWithFormat:@"音量 %f",voiceSound];
}

- (IBAction)recordbtn:(id)sender {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[ZLAudioDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
     {
         if (error) {
             NSLog(@"failure to start recording");
         }
     }];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(setVoiceImage)
                                            userInfo:nil
                                             repeats:YES];
}

- (IBAction)stopbtn:(id)sender {
    [[ZLAudioDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            fp = recordPath;
            NSLog(@"%@",recordPath);
            //            [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
        }
        else {
            NSLog(@"The recording time is too short");
        }
    }];
    
    [_timer invalidate];
    _timer = nil;
}
- (IBAction)playbtn:(id)sender {
    [[ZLAudioDeviceManager sharedInstance] asyncPlayingWithPath:fp completion:^(NSError *error) {
        NSLog(@"playButton %@",error);
        
        // 播放音频
        [[ZLAudioDeviceManager sharedInstance] playNewMessageSound];
        // 震动
        [[ZLAudioDeviceManager sharedInstance] playVibration];
        
    }];
}

@end
