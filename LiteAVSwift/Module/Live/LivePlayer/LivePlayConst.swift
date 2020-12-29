//
//  LiveConst.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

//缓冲策略配置
let CACHE_TIME_FAST:Float   = 1.0
let CACHE_TIME_SMOOTH:Float = 5.0

//路径
let livePlayerBundle = Bundle.main.path(forResource: "Live", ofType: "bundle")

//否模拟器环境
func isSimulator() -> Bool {
    var isSim = false
    #if arch(i386) || arch(x86_64)
        isSim = true
    #endif
    return isSim
}

//缓冲策略
enum CACHE_STRATEGY:String {
    case fast   = "极速"
    case smooth = "流畅"
    case auto   = "自动"
}

//房间工具栏
enum LivePlayerBar:Int {
    case play    = 0 /// 日志
    case log = 1 //浮窗
    case hw = 2//美颜面板
    case rotate = 3//切换相机
    case mode   = 4//是否静音
    case cache    = 5//背景音乐
    case acc    = 6//设置
}
var bottomImages:Array<Dictionary<LivePlayerBar,[String]>> = [
    [LivePlayerBar.play:["start","suspend"]],
    [LivePlayerBar.log:["log","log2"]],
    [LivePlayerBar.hw:["quick2","quick"]],
    [LivePlayerBar.rotate:["portrait","landscape"]],
    [LivePlayerBar.mode:["fill","adjust"]],
    [LivePlayerBar.cache:["cache_time","cache_time"]],
    [LivePlayerBar.acc:["jisu_off","jisu_on"]]
]
