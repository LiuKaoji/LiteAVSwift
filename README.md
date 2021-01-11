## LiteAVSwift

## 简介
用于简单演示LiteAVSDK的自采集和渲染,CDN播放

## 功能说明
* **自定义采集**: 通过采集+滤镜发送给移动直播/实时音视频
* **纹理预处理**: 移动直播的预处理
* **美颜老接口**: 实时音视频老版本渲染回调,支持数据回填实现美颜/滤镜
* **美颜新接口**: 实时音视频8.0+数据回调,支持数据回填实现美颜/滤镜,性能更好
* **直播播放器**: 拉取移动直播/腾讯云点播/实时音视频CDN流
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
## 安装
```bash
$ pod install
```

## 配置
```bash
$ 填写你的sdkappid和secretKey->GenerateTestUserSig.swift
$ 填写移动直播证书,并注意bundleId是否匹配->AppDelegate.swift
```
