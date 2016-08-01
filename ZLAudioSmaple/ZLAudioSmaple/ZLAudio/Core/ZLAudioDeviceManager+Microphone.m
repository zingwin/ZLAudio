/*------------------------------------------------------------
 *  ______  _   _   _____   _   _    _        _   ___    _
 * |___  / | | | | /  _  \ | | | |  | |      |_| |   \  | |
 *    / /  | |_| | | | | | | | | |  | |       _  |  \ \ | |
 *   / /   |  _  | | | | | | | | |  | |      | | | | \ \| |
 *  / /__  | | | | | |_| | | |_| |  | |____  | | | |  \   |
 * /_____| |_| |_| \_____/ \_____/  |______\ |_| |_|   \__|
 *
 *                   May. 26 2014 @马上科技
 ------------------------------------------------------------*/

#import "ZLAudioDeviceManager+Microphone.h"
#import "ZLAudioRecorderUtil.h"

@implementation ZLAudioDeviceManager (Microphone)
// Check the availability for microphone
- (BOOL)checkMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    
    return ret;
}

// Get the audio volumn (0~1)
- (double)peekRecorderVoiceMeter{
    double ret = 0.0;
    if ([ZLAudioRecorderUtil recorder].isRecording) {
        [[ZLAudioRecorderUtil recorder] updateMeters];
        //Average volumn  [recorder averagePowerForChannel:0];
        //Maximum volumn  [recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [[ZLAudioRecorderUtil recorder] peakPowerForChannel:0]));
        ret = lowPassResults;
    }
    
    return ret;
}
@end
