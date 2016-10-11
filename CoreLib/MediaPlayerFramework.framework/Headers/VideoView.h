//
//  VideoView.h
//  MediaPlayer
//
//  Created by Think on 16/2/14.
//  Copyright © 2016年 Cell. All rights reserved.
//

#import <UIKit/UIKit.h>

enum media_player_info_type {
    MEDIA_PLAYER_INFO_BUFFERING_START = 401,
    MEDIA_PLAYER_INFO_BUFFERING_END = 402,
    
    MEDIA_PLAYER_INFO_VIDEO_RENDERING_START = 403,
    
    MEDIA_PLAYER_INFO_NOT_SEEKABLE = 404,
    
    MEDIA_PLAYER_INFO_AUDIO_EOS = 405,
    
    MEDIA_PLAYER_INFO_ASYNC_PREPARE_ALREADY_PENDING = 406,
    
    MEDIA_PLAYER_INFO_REAL_BITRATE = 410,
    MEDIA_PLAYER_INFO_REAL_FPS = 411,
    MEDIA_PLAYER_INFO_REAL_BUFFER_DURATION = 412,
    
    MEDIA_PLAYER_INFO_CONNECTED_SERVER = 601,
    MEDIA_PLAYER_INFO_DOWNLOAD_STARTED = 602,
    MEDIA_PLAYER_INFO_GOT_FIRST_KEY_FRAME = 603,
};

enum media_player_error_type {
    MEDIA_PLAYER_ERROR_DEMUXER_READ_FAIL = 210,
    MEDIA_PLAYER_ERROR_VIDEO_DECODE_FAIL = 211,
    MEDIA_PLAYER_ERROR_AUDIO_DECODE_FAIL = 212,
    
    MEDIA_PLAYER_ERROR_SOURCE_URL_INVALID = 301,
    MEDIA_PLAYER_ERROR_DEMUXER_PREPARE_FAIL = 302,
    MEDIA_PLAYER_ERROR_VIDEO_DECODER_OPEN_FAIL = 303,
    MEDIA_PLAYER_ERROR_VIDEO_RENDER_OPEN_FAIL = 304,
    MEDIA_PLAYER_ERROR_AUDIO_PLAYER_PREPARE_FAIL = 305,
};

enum DataSourceType {
    UNKNOWN = 0,
    LIVE_HIGH_DELAY = 1,
    LIVE_LOW_DELAY = 2,
    VOD_HIGH_CACHE = 3,
    VOD_LOW_CACHE = 4,
    LOCAL_FILE = 5,
};

@protocol VideoViewDelegate <NSObject>
@required
- (void)didPrepare;
- (void)gotErrorWithErrorType:(int)errorType;
- (void)gotInfoWithInfoType:(int)infoType InfoValue:(int)infoValue;
- (void)gotComplete;
- (void)gotVideoSizeChangedWithVideoWidth:(int)width VideoHeight:(int)height;
- (void)gotBufferingUpdateWithPercent:(int)percent;
- (void)gotSeekComplete;
@optional
@end

@interface VideoView : UIView

- (void)initialize;
- (void)setDataSourceWithUrl:(NSString*)url DataSourceType:(int)type;
- (void)prepareAsync;
- (void)start;
- (void)pause;
- (void)stop:(BOOL)blackDisplay;
- (void)seekTo:(NSTimeInterval)seekPosMs;
- (void)terminate;

- (void)setScreenOn:(BOOL)on;

@property (nonatomic, weak) id<VideoViewDelegate> delegate;

@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) NSTimeInterval currentPlaybackTime;

@end
