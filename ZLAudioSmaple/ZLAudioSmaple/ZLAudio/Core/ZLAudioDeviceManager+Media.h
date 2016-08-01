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

#import "ZLAudioDeviceManager.h"

@interface ZLAudioDeviceManager (Media)
#pragma mark - AudioPlayer
// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;
// Stop playing
- (void)stopPlaying;

- (void)stopPlayingWithChangeCategory:(BOOL)isChange;

-(BOOL)isPlaying;

#pragma mark - AudioRecorder
// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion;

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion;
// Cancel recording
-(void)cancelCurrentRecording;

-(BOOL)isRecording;

// Get the saved data path
+ (NSString*)dataPath;

@end
