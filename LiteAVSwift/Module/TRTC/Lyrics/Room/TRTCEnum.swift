//
//  TRTCEnum.swift
//  TRTCSwift
//
//  Created by Kaoji on 2020/4/16.
//  Copyright © 2020 by Kaoji. All rights reserved.
//
//应用场景：视频通话、在线直播
enum TRTCSceneType:Int {
    case trtcVideoCall = 1
    case trtcLive = 2
}

//CDN播放器缓存类型
enum TRTCCdnPlayerCacheType:Int {
    case fast = 1
    case smooth = 2
    case auto = 3
}

//视频输入源
enum TRTCVideoSource:Int {
    case camera = 0
    case custom = 1
    case screen = 2
}

//视频画面的类型
enum VideoViewAreaType:Int {
    case local = 0
    case remote = 1
}

//视频画面大小的类型
enum videoViewSizeType:Int {
    case small = 0
    case big = 1
}

//成员画面约束模式
enum TCLayoutType:Int {
    case TC_Float = 0
    case TC_Gird = 1
}


//房间工具栏
enum TRTCRoomBar:Int {
    case log    = 0 /// 日志
    case layout = 1 //浮窗
    case beauty = 2//美颜面板
    case camera = 3//切换相机
    case mute   = 4//是否静音
    case bgm    = 5//背景音乐
    case set    = 6//设置
    case remote = 7//远程用户列表
    
    //枚举计数
    static let count: Int = {
        var max: Int = 0
        while let _ = TRTCRoomBar(rawValue: max) { max += 1 }
        return max
    }()
}

//音频弹窗Frame类型
enum AudioEffectSettingViewType:Int{
    case defaultType = 0
    case customType = 1
}

//用于标识音效类型
enum AudioEffectStructType:Int{
    case voiceChanger = 0
    case reverb = 1
}
