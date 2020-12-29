//
//  LivePlayerVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/9/17.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LivePlayerVC: UIViewController {
    
    //RXSwift生命周期对象管理
    let disposeBag = DisposeBag()
    
    //播放器界面视图
    lazy var playerView :LivePlayerView = {
        let view = LivePlayerView.init(frame: self.view.frame)
        return view
    }()
    
    //封装的用于调试的播放器
    lazy var debugPlayer:LiveDebugPlayer = {
        let player = LiveDebugPlayer.defaultPlayer(containView: self.playerView.videoView)
        return player
    }()
    
    //当前的缓冲策略 默认自动
    var strategyType = CACHE_STRATEGY.auto
    
    //缓冲策略选择器
    lazy var strategySelector:LiveStrategySelector = {
        return LiveStrategySelector.instance(currentType: .auto) { [weak self](type) in
            self?.strategyType = type
            self?.debugPlayer.setStrategy(type)
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        setupPlayerView()
    }
    
    //MARK:-- -UI
    func setupPlayerView(){
        
        self.view = playerView
        
        playerView.linkInputView.text = debugPlayer.playURL
        
        setupControlEvents()//UI交互事件
        
        //点击二维码
        playerView.qrTap.rx.event.subscribe { (event) in
            self.debugPlayer.stopPlay()
            QRCodeTool.showQRSCan { [weak self](result) -> (Void) in
                self?.refreshPlayType(playUrl: result)
            }
        }.disposed(by: disposeBag)
        
        //播放器抛出消息
        debugPlayer.messageHandler = { [weak self] msg in
            self?.toastMessage(msg)
        }
        
        //播放器停止事件(断网/播放结束/手动调用)
        debugPlayer.stopHandler = { [weak self] endAction in
            let logBtn = self?.playerView.playerBarDict[.log]
            logBtn?.isSelected = false
            
            let playBtn = self?.playerView.playerBarDict[.play]
            playBtn?.isSelected = false
        }
        
    }
    
    //MARK:-- -扫描结果校验
    func refreshPlayType(playUrl:String){
           
        let isHttp_s = playUrl.hasPrefix("http:")||playUrl.hasPrefix("https:")
        if playUrl.hasPrefix("rtmp:") {
            debugPlayer.playType = .PLAY_TYPE_LIVE_RTMP
        }else if(isHttp_s && (playUrl.contains(".flv"))){
            debugPlayer.playType = .PLAY_TYPE_LIVE_FLV
            
        }else if(isHttp_s && (playUrl.contains(".m3u8"))){
            debugPlayer.playType = .PLAY_TYPE_VOD_HLS
        }else{
            //地址不合法 清空
            self.playerView.linkInputView.text = nil
            return
        }
        self.debugPlayer.playURL = playUrl
        self.playerView.linkInputView.text = playUrl
    }
    
    //MARK:-- -菜单栏的按钮事件
    func setupControlEvents(){
        
        //开始暂停
        let playBtn = playerView.playerBarDict[.play]
        playBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            playBtn?.isSelected = !playBtn!.isSelected
            self?.debugPlayer.setIsPlaying = (playBtn?.isSelected)!
        }).disposed(by: disposeBag)
        
        //日志显示
        let logBtn = playerView.playerBarDict[.log]
        logBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            logBtn?.isSelected = !logBtn!.isSelected
            self?.debugPlayer.isShowLog = (logBtn?.isSelected)!
        }).disposed(by: disposeBag)
        
        //软硬解
        let hwBtn = playerView.playerBarDict[.hw]
        hwBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            hwBtn?.isSelected = !hwBtn!.isSelected
            self?.debugPlayer.isHW = (hwBtn?.isSelected)!
        }).disposed(by: disposeBag)
        
        //横竖屏
        let rotateBtn = playerView.playerBarDict[.rotate]
        rotateBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            rotateBtn?.isSelected = !rotateBtn!.isSelected
            self?.debugPlayer.isPortraint = (rotateBtn?.isSelected)!
        }).disposed(by: disposeBag)
        
        //渲染
        let renderBtn = playerView.playerBarDict[.mode]
        renderBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            renderBtn?.isSelected = !renderBtn!.isSelected
            self?.debugPlayer.isRenderScreen = (renderBtn?.isSelected)!
        }).disposed(by: disposeBag)
        
        
        //延迟调整
        let delayBtn = playerView.playerBarDict[.cache]
        delayBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            self?.strategySelector.show(self!)
        }).disposed(by: disposeBag)
        
        //极速模式还是低延时
        let fastBtn = playerView.playerBarDict[.acc]
        fastBtn?.rx.tap.subscribe(onNext: { [weak self](event) in
            fastBtn?.isSelected = !fastBtn!.isSelected
            self?.switchLiveAndAcc((fastBtn?.isSelected)!)
        }).disposed(by: disposeBag)
        
        //返回
        playerView.backBtn.rx.tap.subscribe(onNext: { [weak self](event) in
            self?.backToFloatWindow()
        }).disposed(by: disposeBag)
        
        //帮助按钮
        playerView.helpBtn.rx.tap.subscribe(onNext: { [weak self](event) in
            self?.debugPlayer.stopPlay()
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }
    
    func backToFloatWindow(){
        
        if debugPlayer.livePlayer.isPlaying() {
            LiveFloatWindow.getShared().setupFloatWindow(debugPlayer)
            LiveFloatWindow.getShared().backController = self
        }
        navigationController?.popViewController(animated: true)
        
    }
    
    func switchLiveAndAcc(_ isAcc:Bool){
        
        self.debugPlayer.stopPlay()
        if(isAcc == false){
            self.debugPlayer.playURL = self.playerView.linkInputView.placeholder!
            self.playerView.titleLabel.text = "直播播放器"
            self.debugPlayer.playType = .PLAY_TYPE_LIVE_FLV
            return
        }
         
        self.playerView.titleLabel.text = "低延时播放器"
        self.debugPlayer.playType = .PLAY_TYPE_LIVE_RTMP_ACC
        self.playerView.linkInputView.text = "载入中..."
        //获取测试ACC加速流地址
        let fetchURL = "https://lvb.qcloud.com/weapp/utils/get_test_rtmpaccurl"
        let request  = URLRequest.init(url: URL.init(string: fetchURL)!)
        let session  = URLSession.init(configuration: .default, delegate: nil, delegateQueue: .main)
        let dataTask = session.dataTask(with: request) { [weak self](data, response, error) in
            if(error != nil){
                self?.toastMessage("获取低延时播放地址失败\(error?.localizedDescription ?? "未知")")
                self?.playerView.linkInputView.text = "加载失败!"
            }else{
                
                let dataDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                let rtmpACCURL = (dataDict as! Dictionary<String, Any>)["url_rtmpacc"]
                self?.playerView.linkInputView.text = rtmpACCURL! as? String
                self?.debugPlayer.playURL = (rtmpACCURL! as? String)!
                self?.toastMessage("获取低延时播放地址成功")
            }
        }
        dataTask.resume()
    }
    
    //MARK:-- -提示
    func toastMessage(_ msg:String){
        
        NSObject.cancelPreviousPerformRequests(withTarget: hideToastView())
        let toastView = playerView.toastView
        toastView.isHidden = false
        toastView.text = msg
        let size = toastView.sizeThatFits(.init(width: toastView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        toastView.snp.updateConstraints { (make) in
            make.height.equalTo(size.height)
        }
        self.perform(#selector(hideToastView), with: nil, afterDelay: 2.0)
    }

    @objc func hideToastView(){
        let toastView = playerView.toastView
        toastView.isHidden = true
    }
    
}

