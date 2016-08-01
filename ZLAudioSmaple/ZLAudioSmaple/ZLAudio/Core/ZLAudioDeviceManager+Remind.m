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

#import "ZLAudioDeviceManager+Remind.h"

void zlSystemSoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
    AudioServicesDisposeSystemSoundID(sound_id);
}


@implementation ZLAudioDeviceManager (Remind)
// The system sound for a new message
- (SystemSoundID)playNewMessageSound
{
    // Path for the audio file
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"in" withExtension:@"caf"];
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(audioPath), &soundID);
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(soundID,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          zlSystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(soundID);
    
    return soundID;
}

- (void)playVibration
{
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate,
                                          NULL, // uses the main run loop
                                          NULL, // uses kCFRunLoopDefaultMode
                                          zlSystemSoundFinishedPlayingCallback, // the name of our custom callback function
                                          NULL // for user data, but we don't need to do that in this case, so we just pass NULL
                                          );
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
@end
