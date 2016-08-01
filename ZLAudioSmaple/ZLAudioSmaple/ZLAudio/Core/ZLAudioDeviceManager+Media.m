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

#import "ZLAudioDeviceManager+Media.h"
#import "ZLAudioPlayerUtil.h"
#import "ZLAudioRecorderUtil.h"
#import "ZLVoiceConverter.h"
#import "ZLAudioErrorCode.h"

typedef NS_ENUM(NSInteger, EMAudioSession){
    EM_DEFAULT = 0,
    EM_AUDIOPLAYER,
    EM_AUDIORECORDER
};

@implementation ZLAudioDeviceManager (Media)
#pragma mark - AudioPlayer

+ (NSString*)dataPath
{
    NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:dataPath]){
        [fm createDirectoryAtPath:dataPath
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    return dataPath;
}

// Play the audio
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    BOOL isNeedSetActive = YES;
    // Cancel if it is currently playing
    if([ZLAudioPlayerUtil isPlaying]){
        [ZLAudioPlayerUtil stopCurrentPlaying];
        isNeedSetActive = NO;
    }
    
    if (isNeedSetActive) {
        [self setupAudioSessionCategory:EM_AUDIOPLAYER
                               isActive:YES];
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *wavFilePath = [[aFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"wav"];
    if (![fileManager fileExistsAtPath:wavFilePath]) {
        BOOL covertRet = [self convertAMR:aFilePath toWAV:wavFilePath];
        if (!covertRet) {
            if (completon) {
                completon([NSError errorWithDomain:@"File format conversion failed"
                                              code:ZLErrorFileTypeConvertionFailure
                                          userInfo:nil]);
            }
            return ;
        }
    }
    [ZLAudioPlayerUtil asyncPlayingWithPath:wavFilePath
                                 completion:^(NSError *error)
     {
         [self setupAudioSessionCategory:EM_DEFAULT
                                isActive:NO];
         if (completon) {
             completon(error);
         }
     }];
}

- (void)stopPlaying{
    [ZLAudioPlayerUtil stopCurrentPlaying];
    [self setupAudioSessionCategory:EM_DEFAULT
                           isActive:NO];
}

- (void)stopPlayingWithChangeCategory:(BOOL)isChange{
    [ZLAudioPlayerUtil stopCurrentPlaying];
    if (isChange) {
        [self setupAudioSessionCategory:EM_DEFAULT
                               isActive:NO];
    }
}

- (BOOL)isPlaying{
    return [ZLAudioPlayerUtil isPlaying];
}

#pragma mark - Recorder

+(NSTimeInterval)recordMinDuration{
    return 1.0;
}

// Start recording
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion{
    NSError *error = nil;
    
    if ([self isRecording]) {
        if (completion) {
            error = [NSError errorWithDomain:@"Record voice is not over yet"
                                        code:ZLErrorAudioRecordStoping
                                    userInfo:nil];
            completion(error);
        }
        return ;
    }
    
    if (!fileName || [fileName length] == 0) {
        error = [NSError errorWithDomain:@"File path not exist"
                                    code:-1
                                userInfo:nil];
        completion(error);
        return ;
    }
    
    BOOL isNeedSetActive = YES;
    if ([self isRecording]) {
        [ZLAudioRecorderUtil cancelCurrentRecording];
        isNeedSetActive = NO;
    }
    
    [self setupAudioSessionCategory:EM_AUDIORECORDER
                           isActive:YES];
    
    _recorderStartDate = [NSDate date];
    
    NSString *recordPath = [NSString stringWithFormat:@"%@/%@", [ZLAudioDeviceManager dataPath], fileName];
    [ZLAudioRecorderUtil asyncStartRecordingWithPreparePath:recordPath
                                                 completion:completion];
}

// Stop recording
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion{
    NSError *error = nil;
    
    if(![self isRecording]){
        if (completion) {
            error = [NSError errorWithDomain:@"Recording has not yet begun"
                                        code:ZLErrorAudioRecordNotStarted
                                    userInfo:nil];
            completion(nil,0,error);
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    _recorderEndDate = [NSDate date];
    
    if([_recorderEndDate timeIntervalSinceDate:_recorderStartDate] < [ZLAudioDeviceManager recordMinDuration]){
        if (completion) {
            error = [NSError errorWithDomain:@"Recording time is too short"
                                        code:ZLErrorAudioRecordDurationTooShort
                                    userInfo:nil];
            completion(nil,0,error);
        }
        
        // If the recording time is too shorty，in purpose delay one second
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([ZLAudioDeviceManager recordMinDuration] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [ZLAudioRecorderUtil asyncStopRecordingWithCompletion:^(NSString *recordPath) {
                [weakSelf setupAudioSessionCategory:EM_DEFAULT isActive:NO];
            }];
        });
        return ;
    }
    
    [ZLAudioRecorderUtil asyncStopRecordingWithCompletion:^(NSString *recordPath) {
        if (completion) {
            if (recordPath) {
                // Convert wav to amr
                NSString *amrFilePath = [[recordPath stringByDeletingPathExtension]
                                         stringByAppendingPathExtension:@"amr"];
                BOOL convertResult = [self convertWAV:recordPath toAMR:amrFilePath];
                if (convertResult) {
                    // Remove the wav
                    NSFileManager *fm = [NSFileManager defaultManager];
                    [fm removeItemAtPath:recordPath error:nil];
                }
                completion(amrFilePath,(int)[self->_recorderEndDate timeIntervalSinceDate:self->_recorderStartDate],nil);
            }
            [weakSelf setupAudioSessionCategory:EM_DEFAULT isActive:NO];
        }
    }];
}

// Cancel recording
-(void)cancelCurrentRecording{
    [ZLAudioRecorderUtil cancelCurrentRecording];
}

-(BOOL)isRecording{
    return [ZLAudioRecorderUtil isRecording];
}

#pragma mark - Private
-(NSError *)setupAudioSessionCategory:(EMAudioSession)session
                             isActive:(BOOL)isActive{
    BOOL isNeedActive = NO;
    if (isActive != _currActive) {
        isNeedActive = YES;
        _currActive = isActive;
    }
    NSError *error = nil;
    NSString *audioSessionCategory = nil;
    switch (session) {
        case EM_AUDIOPLAYER:
            audioSessionCategory = AVAudioSessionCategoryPlayback;
            break;
        case EM_AUDIORECORDER:
            audioSessionCategory = AVAudioSessionCategoryRecord;
            break;
        default:
            audioSessionCategory = AVAudioSessionCategoryAmbient;
            break;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    if (![_currCategory isEqualToString:audioSessionCategory]) {
        [audioSession setCategory:audioSessionCategory error:nil];
    }
    if (isNeedActive) {
        BOOL success = [audioSession setActive:isActive
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
        if(!success || error){
            error = [NSError errorWithDomain: @"Failed to initialize AVAudioPlayer"
                                        code:-1
                                    userInfo:nil];
            return error;
        }
    }
    _currCategory = audioSessionCategory;
    
    return error;
}

#pragma mark - Convert

- (BOOL)convertAMR:(NSString *)amrFilePath
             toWAV:(NSString *)wavFilePath
{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
    if (isFileExists) {
        [ZLVoiceConverter amrToWav:amrFilePath wavSavePath:wavFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}

- (BOOL)convertWAV:(NSString *)wavFilePath
             toAMR:(NSString *)amrFilePath {
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        [ZLVoiceConverter wavToAmr:wavFilePath amrSavePath:amrFilePath];
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:amrFilePath];
        if (!isFileExists) {
            
        } else {
            ret = YES;
        }
    }
    
    return ret;
}
@end
