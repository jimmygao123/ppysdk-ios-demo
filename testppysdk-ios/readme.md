
##推流端：
`PPPushService *pushService = [[PPPushService alloc]init];`

###参数配置：
####音频
`
PPYAudioConfiguration *audioConfigure = [PPYAudioConfiguration defaultAudioConfiguration];
`
####视频
`
PPYVideoConfiguration *videoConfigure = [PPYVideoConfiguration defaultVideoCOnfiguration];
`

#####支持音视频参数Level调解：
`
+(instancetype)videoConfigurationWithVideoQuality:(PPYVideoQuality)videoQuality;
+(instancetype)audioConfigurationWithAudioQuality:(PPYAudioQuality)audioQuality;
`
#####支持音视频参数自定义，可以调用：
`
+(instancetype)audioConfigurationWithSamplerate:(PPYAudioSampleRate)samplerate andChannelCount:(int)channelCount andBirate:(PPYAudioBitRate)bitrate;
+(instancetype)videoConfigurationWithPreset:(PPYCaptureSessionPreset)videoPreset andFPS:(PPYCaptureFPS)fps andBirate:(int)bitrate; //kbps
`
###推流引擎初始化：
`PPYPushEngine *pushEngine = []PPYPushEngine alloc]initWithAudioConfiguration:audioConfigure andVideoConfiguration:videoConfigure pushRTMPAddress:rtmpAddress;
`
###设置代理：
`pushEngine.delegate = self;
`
###代理监听流状态，流信息，抛出错误
`-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status｛
｝
-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error｛
｝
-(void)didStreamInfoThrowOut:(PPYPushEngineStreamInfoType)type infoValue:(int)value｛
｝
`

###建立视频预览：
`pushEngine.preview = self.view`

###开始视频预览：
`pushEngine.running = YES;`
###开始推流：
`[pushEngine start]`

###结束推流：
`[pushEngine stop];`

###切换摄像头：
`pushEngine.cameraPosition = AVCaptureDevicePositionFront;
pushEngine.cameraPosition = AVCaptureDevicePositionBack;
`
###闪光灯：
`pushEngine.torch = YES;
 pushEngine.torch = NO;
`
        
###自动连续对焦：
`if(pushEngine.hasFocus){
        pushEngine.autoFocus = YES;
 }
 if(pushEngine.hasFocus){
        pushEngine.autoFocus = NO;
 }
`
        
###手动对焦：
`CGPoint location = [touch locationInView:self.view];
 [pushEngine doFocusOnPoint:location onView:self.view needDisplayLocation:YES];
 `
###美颜：
`
pushEngine.beautify = YES;
pushEngine.beautyLevel = 0.5;
pushEngine.brightLevel = 0.5;
pushEngine.toneLevel = 0.5;
`
###静音开关：
`pushEngine.mute = YES;
`



##播放端：

###初始化：
`
pullEngine = [[PPYPullEngine alloc]initWithRTMPAddr:self.playAddress];
`
###设置代理：
`
pullEngine.delegate = self;
`
###设置预览：
`
pullEngine.preview = self.view;
`
###开始播放：
`
[pullEngine startPlay];
`
###代理获取播放状态
`
-(void)playerStateChanged:(PPYPlayerStatus)status;
`