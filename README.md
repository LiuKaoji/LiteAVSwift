## LiteAVSwift

## 简介
用于简单演示LiteAVSDK的自采集和渲染,CDN播放
```none
┌──────────────┐    ┌──────────────┐
│   Capture    ├────▶   filter     │
└───────┬──────┘    └──────┬───────┘
        │                  │        
┌───────▼──────────────────▼───────┐
│             Live/TRTC            │
└───────▲──────────────────▲───────┘
        │                  │        
┌───────┴──────┐    ┌──────┴───────┐
│Render/Process│    │ Live Player  │
└──────────────┘    └──────────────┘
```

## 移动直播
* **[自定义采集](http://doc.qcloudtrtc.com/group__TXLivePush__ios.html#a6a34781b97eb91cf17773a6073c19ed2)**: 通过采集+滤镜发送给移动直播
```bash
$ TXLivePush.h:
$ TXLivePushConfig.customModeType =  CUSTOM_MODE_VIDEO_CAPTURE;
$ pusher.sendVideoSampleBuffer(sampleBuffer)
```
* **[纹理预处理](http://doc.qcloudtrtc.com/group__TXVideoEditerListener__ios.html#a291f788c080dc4fb941ff5a955e249de)**: 移动直播的预处理
```bash
$ TXLivePush.h:
$ - (id<TXVideoCustomProcessDelegate>) videoProcessDelegate;
$ -(void)onPreProcessTexture...
```
* **[直播播放器](http://doc.qcloudtrtc.com/group__TXLivePlayer__ios.html)**: 拉取移动直播/腾讯云点播/实时音视频CDN流
```bash
$ TXLivePlayer.h:
$ setupVideoWidget 
$ startPlay
```
## 实时音视频
* **[自定义采集](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a76e8101153afc009f374bc2b242c6831)**: 通过采集+滤镜发送给移动直播/实时音视频
```bash
$ TRTCCloud.h:
$ - (void)enableCustomVideoCapture:(BOOL)enable;///开启实时音视频自定义视频采集
$ - (void)sendCustomVideoData:(TRTCVideoFrame *)frame{}///发送TRTCVideoFrame
```

* **[美颜老接口](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#aba3d309645d27304b6d4ea31b21a4cda)**: 实时音视频老版本渲染回调,支持数据回填实现美颜/滤镜 
```bash
$ TRTCCloud.h:
$ setLocalVideoRenderDelegate 
$ -(void)onRenderVideoFrame:(TRTCVideoFrame *)frame userId:(NSString *)userId streamType:(TRTCVideoStreamType)streamType{}
```
* **[美颜新接口](http://doc.qcloudtrtc.com/group__TRTCCloud__ios.html#a2f73c33b1010a63bd3a06e639b3cf348)**: 实时音视频8.0+数据回调,支持数据回填实现美颜/滤镜,性能更好
```bash
$ TRTCCloud.h:
$ setLocalVideoProcessDelegete 
$ - (uint32_t)onProcessVideoFrame:(TRTCVideoFrame * _Nonnull)srcFrame dstFrame:(TRTCVideoFrame * _Nonnull)dstFrame{}
```

## 安装
```bash
$ pod install
```

## 配置
```bash
$ 填写你的sdkappid和secretKey->GenerateTestUserSig.swift
$ 填写移动直播证书,并注意bundleId是否匹配->AppDelegate.swift
```
