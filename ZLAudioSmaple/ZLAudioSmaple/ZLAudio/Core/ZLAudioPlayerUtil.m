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

#import "ZLAudioPlayerUtil.h"
#import <AVFoundation/AVFoundation.h>


@interface ZLAudioPlayerUtil () <AVAudioPlayerDelegate> {
    AVAudioPlayer *_player;
    void (^playFinish)(NSError *error);
}

@end

@implementation ZLAudioPlayerUtil
#pragma mark - public
+ (BOOL)isPlaying{
    return [[ZLAudioPlayerUtil sharedInstance] isPlaying];
}

+ (NSString *)playingFilePath{
    return [[ZLAudioPlayerUtil sharedInstance] playingFilePath];
}

+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    [[ZLAudioPlayerUtil sharedInstance] asyncPlayingWithPath:aFilePath
                                                  completion:completon];
}

+ (void)stopCurrentPlaying{
    [[ZLAudioPlayerUtil sharedInstance] stopCurrentPlaying];
}


#pragma mark - private
+ (ZLAudioPlayerUtil *)sharedInstance{
    static ZLAudioPlayerUtil *audioPlayerUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayerUtil = [[self alloc] init];
    });
    
    return audioPlayerUtil;
}

- (BOOL)isPlaying
{
    return !!_player;
}

// Get the path of what is currently being played
- (NSString *)playingFilePath
{
    NSString *path = nil;
    if (_player && _player.isPlaying) {
        path = _player.url.path;
    }
    
    return path;
}

- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    playFinish = completon;
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:aFilePath]) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:-1
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        
        return;
    }
    
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aFilePath];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
    if (error || !_player) {
        _player = nil;
        error = [NSError errorWithDomain:@"Failed to initialize AVAudioPlayer"
                                    code:-1
                                userInfo:nil];
        if (playFinish) {
            playFinish(error);
        }
        playFinish = nil;
        return;
    }
    
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
}

- (void)stopCurrentPlaying{
    if(_player){
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    if (playFinish) {
        playFinish = nil;
    }
}

- (void)dealloc{
    if (_player) {
        _player.delegate = nil;
        [_player stop];
        _player = nil;
    }
    playFinish = nil;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    if (playFinish) {
        playFinish(nil);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
    playFinish = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error{
    if (playFinish) {
        NSError *error = [NSError errorWithDomain:@"Play failure"
                                             code:-1
                                         userInfo:nil];
        playFinish(error);
    }
    if (_player) {
        _player.delegate = nil;
        _player = nil;
    }
}
@end
