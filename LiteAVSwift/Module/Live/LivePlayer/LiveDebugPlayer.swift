//
//  LiveDebugPlayer.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/20.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LiveDebugPlayer: NSObject,TXLivePlayListener {
    
    //播放地址
    var playURL:String = "http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv"//默认播放地址
    
    //播放器类型 需要与API匹配
    var playType:TX_Enum_PlayType = .PLAY_TYPE_LIVE_FLV//播放类型
    
    //播放器
    var livePlayer:TXLivePlayer!
    
    //播放器控件
    var videoView:LiveVideoView!
    
    //义一个block 返回字符串
    typealias DebugPlayerHandler = ((String) -> (Void))
    
    //将播放器的相关提示抛出
    var messageHandler:DebugPlayerHandler?
    
    //播放器停止事件
    var stopHandler:DebugPlayerHandler?
    
    //是否禁止熄屏
    var idleTimerDisabled:Bool = false{
        didSet{
            UIApplication.shared.isIdleTimerDisabled = idleTimerDisabled
        }
    }
    
    //播放还是暂停
    var setIsPlaying:Bool = false{
        didSet{
            setIsPlaying ?startPlay():stopPlay()
        }
    }
    
    //日志显示与隐藏
    var isShowLog:Bool = false {
        didSet{
            debugPrint("选择?\(isShowLog)")
            livePlayer.setLogViewMargin(.init(top: 130, left: 10, bottom: 60, right: 10))
            livePlayer.showVideoDebugLog(isShowLog)
            
        }
    }
    
    //是否硬解(模拟器必须硬解 软解红屏)
    var isHW:Bool = isSimulator() ?true:false {
        didSet{
            livePlayer.stopPlay()
            livePlayer.enableHWAcceleration = isHW
            startPlay()
            throwMessageOut("切换成\(isHW ?"硬解":"软解"),重启播放流程")
        }
    }
    
    //渲染模式
    var isRenderScreen:Bool = false {
        didSet{
            let mode = isRenderScreen ?TX_Enum_Type_RenderMode.RENDER_MODE_FILL_SCREEN:TX_Enum_Type_RenderMode.RENDER_MODE_FILL_EDGE
            livePlayer.setRenderMode(mode)
        }
    }
    
    //横竖屏切换
    var isPortraint:Bool = true {
        didSet{
            let rotation = isPortraint ?TX_Enum_Type_HomeOrientation.HOME_ORIENTATION_DOWN:TX_Enum_Type_HomeOrientation.HOME_ORIENTATION_RIGHT
            livePlayer.setRenderRotation(rotation)
        }
    }
    
    open class func defaultPlayer(containView:LiveVideoView)->LiveDebugPlayer{
        
        //播放器配置
        let config = TXLivePlayConfig()
        config.enableMessage = true
        
        //模拟器默认开启硬解 因为模拟器不硬解会报错 红屏
        let livePlayr = TXLivePlayer()
        livePlayr.enableHWAcceleration = isSimulator() ?true:false
        livePlayr.setRenderMode(.RENDER_MODE_FILL_EDGE)
    
        //本类封装的播放器
        let debugPlayer = LiveDebugPlayer()
        debugPlayer.videoView = containView
        debugPlayer.livePlayer = livePlayr
        
        return debugPlayer
    }
    
    //开始播放
    func startPlay(){
        guard !livePlayer.isPlaying() else {return}
        livePlayer.setupVideoWidget(.zero, contain: videoView, insert: 0)
        videoView.loadingView.startAnimating()
        livePlayer.delegate = self
        livePlayer.startPlay(playURL, type: playType)
    }
    
    //暂停播放
    func stopPlay(){
        videoView.loadingView.isAnimating ?videoView.loadingView.stopAnimating():nil
        guard livePlayer.isPlaying() else {return}
        livePlayer.stopPlay()
        livePlayer.removeVideoWidget()
        livePlayer.delegate = nil
        //停止事件
        if((self.stopHandler) != nil){
            self.stopHandler!("")
        }
    }
    
    //设置缓存时间
    func setStrategy(_ type:CACHE_STRATEGY){
        
        let config = livePlayer.config!
        switch (type) {
        case .fast:
            config.bAutoAdjustCacheTime = true
            config.minAutoAdjustCacheTime = CACHE_TIME_FAST
            config.maxAutoAdjustCacheTime = CACHE_TIME_FAST
            livePlayer.config = config
            break;
            
        case .smooth:
            config.bAutoAdjustCacheTime = false
            config.minAutoAdjustCacheTime = CACHE_TIME_SMOOTH
            config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH
            livePlayer.config = config
            break;
            
        case .auto:
            config.bAutoAdjustCacheTime = false
            config.minAutoAdjustCacheTime = CACHE_TIME_FAST
            config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH
            livePlayer.config = config
            break;
        }
    }
    
    
    //MARK: -- -TXLivePlayListener
    func onPlayEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.recievedPlayEvent(EvtID, withParam: param)
        }
    }
    
    func onNetStatus(_ param: [AnyHashable : Any]!) {
        DispatchQueue.main.async {
            self.recievedNetStatus(param)
        }
    }
    
    func recievedPlayEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN.rawValue) {
            videoView.loadingView.stopAnimating()
            
        }else if (EvtID == PLAY_ERR_NET_DISCONNECT.rawValue || EvtID == PLAY_EVT_PLAY_END.rawValue) {
            // 断开连接时，模拟点击一次关闭播放
            videoView.loadingView.stopAnimating()
            self.stopPlay()
            if (EvtID == PLAY_ERR_NET_DISCONNECT.rawValue) {
                throwMessageOut(param!["EVT_MSG"] as! String)
            }
            
        }else if (EvtID == PLAY_EVT_PLAY_LOADING.rawValue){
            videoView.loadingView.startAnimating()
        }else if (EvtID == PLAY_EVT_GET_MESSAGE.rawValue) {
            let msgData = param["EVT_GET_MSG"]
            let msg = String.init(data: msgData as! Data, encoding: .utf8)
            throwMessageOut(msg!)
        }else{
            let event = param!["EVT_MSG"] as? String
            if event?.count ?? 0 > 0 && self.messageHandler != nil {
                //throwMessageOut(event!)
            }
            
        }
        
    }
    
    func recievedNetStatus(_ param: [AnyHashable : Any]!) {
        
    }
    
    //Toast信息抛出
    func throwMessageOut(_ string:String) {
        //停止事件
        if((self.messageHandler) != nil){
            self.messageHandler!(string)
        }
    }
}

