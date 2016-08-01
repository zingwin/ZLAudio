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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZLAudioRecorderUtil : NSObject
+(BOOL)isRecording;

// Start recording
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// Stop recording
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// Cancel recording
+(void)cancelCurrentRecording;

// Current recorder
+(AVAudioRecorder *)recorder;
@end
