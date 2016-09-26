
## 推流端：
```obj-c
PPPushService *pushService = [[PPPushService alloc]init];
```
#### 参数配置：

##### 音频
```obj-c
PPYAudioConfiguration *audioConfigure = [PPYAudioConfiguration defaultAudioConfiguration];
```
##### 视频
```obj-c
PPYVideoConfiguration *videoConfigure = [PPYVideoConfiguration defaultVideoCOnfiguration];
```

##### 支持音视频参数Level调解：
```obj-c
+(instancetype)videoConfigurationWithVideoQuality:(PPYVideoQuality)videoQuality;

+(instancetype)audioConfigurationWithAudioQuality:(PPYAudioQuality)audioQuality;
```
###### 支持音视频参数自定义，可以调用：
```obj-c
+(instancetype)audioConfigurationWithSamplerate:(PPYAudioSampleRate)samplerate andChannelCount:(int)channelCount andBirate:(PPYAudioBitRate)bitrate;

+(instancetype)videoConfigurationWithPreset:(PPYCaptureSessionPreset)videoPreset andFPS:(PPYCaptureFPS)fps andBirate:(int)bitrate; //kbps
```
#### 推流引擎初始化：
```obj-c
PPYPushEngine *pushEngine = []PPYPushEngine alloc]initWithAudioConfiguration:audioConfigure andVideoConfiguration:videoConfigure pushRTMPAddress:rtmpAddress;
```
#### 设置代理：
```obj-c
pushEngine.delegate = self;
```
#### 代理监听流状态，流信息，抛出异常
```obj-c
-(void)didStreamStateChanged:(PPYPushEngineStreamStatus)status｛
｝
-(void)didStreamErrorOccured:(PPYPushEngineErrorType)error｛
｝
-(void)didStreamInfoThrowOut:(PPYPushEngineStreamInfoType)type infoValue:(int)value｛
｝
```

#### 建立视频预览：
```obj-c
pushEngine.preview = self.view
```
#### 开始视频预览：
```obj-c
pushEngine.running = YES;
```
#### 开始推流：
```obj-c
[pushEngine start]
```

#### 结束推流：
```obj-c
[pushEngine stop];
```

#### 切换摄像头：
```obj-c
pushEngine.cameraPosition = AVCaptureDevicePositionFront;
pushEngine.cameraPosition = AVCaptureDevicePositionBack;
```
#### 闪光灯：
```obj-c
pushEngine.torch = YES;
pushEngine.torch = NO;
```
        
#### 自动连续对焦：
```obj-c
if(pushEngine.hasFocus){
        pushEngine.autoFocus = YES;
}
if(pushEngine.hasFocus){
       pushEngine.autoFocus = NO;
}
```
        
#### 手动对焦：
```obj-c
CGPoint location = [touch locationInView:self.view];
[pushEngine doFocusOnPoint:location onView:self.view needDisplayLocation:YES];
 ```
#### 美颜：
```obj-c
pushEngine.beautify = YES;
pushEngine.beautyLevel = 0.5;
pushEngine.brightLevel = 0.5;
pushEngine.toneLevel = 0.5;
```
#### 静音开关：
```obj-c
pushEngine.mute = YES;
```



## 播放端：

#### 初始化单列对象：
```obj-c
PPYPlayEngine *playEngine = [PPYPlayEngine shareInstance];
```
#### 设置代理：
```obj-c
playEngine.delegate = self;
```
#### 设置播放预览：
```obj-c
[playEngine setPreviewOnView:self.view];
```
#### 开始播放：
```obj-c
NSString *url = @"...";
[playEngine startPlayFromURL:url];
```
#### 停止播放:
```obj-c
[playEngine stop:YES];
```
#### 代理获取播放状态,播放流信息，错误信息
```obj-c

-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value;

-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state;

-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height;

-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error;
```

