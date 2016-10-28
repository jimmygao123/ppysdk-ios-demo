# PP云直播推流SDK使用说明（IOS）
## 一. 功能特点
-  [硬件编码]
-  [网络自适应]：可根据实际网络情况动态调整目标码率，保证流畅性
-  音频编码：AAC
-  视频编码：H.264
-  推流协议：RTMP
-  [视频分辨率]：支持360P, 480P, 540P和720P
-  音视频目标码率：可设
-  支持固定竖屏推流
-  支持前、后置摄像头动态切换
-  闪光灯：开/关
-  [内置美颜功能]
-  [支持手动指定自动对焦测光区域]
## 二. 运行环境
最低支持版本为IOS8.0

支持的CPU架构：armv7,armv7s,arm64
## 三. 快速集成
- ####  配置工程文件：
在工程文件->General->Embedded Binaries项中导入动态库：PPYLiveKit，MediaPlayerFramework,MediaStreamerFramework.

- #### 引入头文件： 
```obj-c
#import <PPYLiveKit/PPYLiveKit.h>
```

- ####  接口说明：
#### 初始化推流引擎：
```obj-c
PPYPushEngine *pushEngine = [[PPYPushEngine alloc]initWithAudioConfiguration:self.audioConfig andVideoConfiguration:self.videoConfig pushRTMPAddress:self.rtmpAddress];;
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
#### 美颜三档参数可调，调节范围0～1.0：
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




# PP云播放SDK使用说明（IOS）
## 一. 功能特点
-  [支持硬解，软解]；
-  [网络自适应]：可根据实际网络情况动态调整目标码率，保证流畅性
-  支持播放流协议：RTMP，HTTP-FLV，HLS

## 二. 运行环境
最低支持版本为IOS8.0

支持的CPU架构：armv7,armv7s,arm64
## 三. 快速集成
- ####  配置工程文件：
在工程文件->General->Embedded Binaries项中导入动态库：PPYLiveKit，MediaPlayerFramework,MediaStreamerFramework.

- #### 引入头文件： 
```obj-c
#import <PPYLiveKit/PPYLiveKit.h>
```
- #### 接口说明及使用方法
##### 初始化单列对象：
```obj-c
PPYPlayEngine *playEngine = [PPYPlayEngine shareInstance];
```
##### 设置代理：
```obj-c
playEngine.delegate = self;
```
##### 播放预览：
```obj-c
[playEngine presentPreviewOnView:self.view];
```
##### 删除播放预览:
```obj-c
[playEngine disappearPreview];
```
##### 开始播放：
```obj-c
NSString *url = @"...";
[playEngine startPlayFromURL:url WithType:PPYSourceType_Live];//直播用PPYSourceType_Live，点播用PPYSourceType_VOD
```
##### 停止播放:
```obj-c
[playEngine stopPlayerBlackDisplayNeeded：YES];//YES表示播放停止时留在一帧画面，NO表示停止时显示黑屏
```
##### 代理获取播放状态,播放流信息，错误信息
```obj-c

-(void)didPPYPlayEngineInfoThrowOut:(PPYPlayEngineInfoType)type andValue:(int)value;

-(void)didPPYPlayEngineStateChanged:(PPYPlayEngineStatus)state;

-(void)didPPYPlayEngineVideoResolutionCaptured:(int)width VideoHeight:(int)height;

-(void)didPPYPlayEngineErrorOccured:(PPYPlayEngineErrorType)error;
```

##### 点播
```obj-c
[playEngine pause] ; //暂停
[playEngine resume]; //恢复播放
NSTimeInterval duration = playEngine.duration ;//获取总时长
NSTimeInterval currentTime = playEngine.currentPlaybackTime;//当前播放时间点；
[playEngine seekToPosition:time]; //到某个时间点继续播放;
```