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

@interface ZLAudioPlayerUtil : NSObject
+ (BOOL)isPlaying;

// Get the path of what is currently being played
+ (NSString *)playingFilePath;

// Play the audio（wav）from the path
+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

+ (void)stopCurrentPlaying;

@end
