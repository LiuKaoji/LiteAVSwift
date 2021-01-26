//
//  RoomVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2021/1/26.
//  Copyright © 2021 kaoji. All rights reserved.
//

import UIKit

class RoomVC: UIViewController,TRTCCloudDelegate, TRTCVideoViewDelegate {
    
    /// rx
    let disposeBag = DisposeBag()
    
    //标题与返回
    lazy var trtc = self.setupTRTC()

    ///本地画面
    var localPlayModel:VideoLayoutModel?
    
    /// RoomView
    var trtcRoomView:TRTCRoomView!
    
    /// 进房参数
    var param:TRTCParams!
    

    required convenience init(rtcParam: TRTCParams) {
        self.init()
        self.param = rtcParam
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        startTRTC()
    }
    
    func setupView(){
        
        trtcRoomView = TRTCRoomView.init(frame: self.view.frame)
        self.view.addSubview(trtcRoomView)
        
        self.trtcRoomView.roomTitle.text = "歌词发送-\(param.roomId)"
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white

        self.trtcRoomView.backBtn.rx.tap.subscribe { [weak self] _ in
            self?.trtc.stopLocalAudio()
            self?.trtc.stopLocalPreview()
            self?.trtc.exitRoom()
            TRTCCloud.destroySharedIntance()
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    func startLocal(){
        
        guard param.role == .anchor else {
            return
        }
        
        //初始化本地预览
        localPlayModel = VideoLayoutModel.init(areaType: .local, userId: USER_ID, vSize: .big, isAvailible: true, vSource: .camera)
        localPlayModel?.player.tapDelegate = self
        trtcRoomView.layoutEngin.subViews.append(localPlayModel!)
        trtcRoomView.layoutEngin.adjustBigAndSmallQueueWithAnimation()
        //启动预览
        trtc.startLocalPreview(true, view: self.localPlayModel?.player)
        trtc .startLocalAudio()
    }
    
    func stopLocal(){
        trtc .stopLocalAudio()
        trtc.stopLocalPreview()
        localPlayModel?.player.removeFromSuperview()
        trtcRoomView.layoutEngin.subViews.removeAll { (model) -> Bool in
            return model.userId == localPlayModel?.userId
        }
    }
    
    func startTRTC(){
        startLocal()
        trtc.delegate = self
        
        //进房
        trtc.enterRoom(self.param, appScene: .LIVE)
        
    }

    
    func onTapVideoView(userId: String) {
        let remotePlayer = trtcRoomView.layoutEngin.isInRoom(userId: userId)
        if remotePlayer != nil {
            trtcRoomView.layoutEngin.exchangeSmallToBig(smallModel: remotePlayer!)
        }
    }
}

extension RoomVC{
    
   // @param result result > 0 时为进房耗时（ms），result < 0 时为进房错误码。
    func onEnterRoom(_ result: Int) {
        
        guard param.role == .anchor && result > 0  else {
            return
        }
    }
    
    /**
     * 3.3 远端用户是否存在可播放的主路画面（一般用于摄像头）
     *
     * 当您收到 onUserVideoAvailable(userid, YES) 通知时，表示该路画面已经有可用的视频数据帧到达。
     * 此时，您需要调用 startRemoteView(userid) 接口加载该用户的远程画面。
     * 然后，您会收到名为 onFirstVideoFrame(userid) 的首帧画面渲染回调。
     *
     * 当您收到 onUserVideoAvailable(userid, NO) 通知时，表示该路远程画面已被关闭，
     * 可能由于该用户调用了 muteLocalVideo() 或 stopLocalPreview()。
     *
     * @param userId 用户标识
     * @param available 画面是否开启
     */
    func onUserVideoAvailable(_ userId: String, available: Bool) {
        
        debugPrint("onUserVideoAvailable:userId:\(userId) available:\(available)")
        
        ///当远端用户进入时UserId不为空
        if userId.isEmpty == false {
            
            var remotePlayer = trtcRoomView.layoutEngin.isInRoom(userId: userId)
            if remotePlayer == nil {
                remotePlayer = VideoLayoutModel.init(areaType: .remote, userId: userId, vSize: .big, isAvailible: available, vSource: .camera)
                remotePlayer?.player.tapDelegate = self
                self.trtcRoomView.layoutEngin.subViews.append(remotePlayer!)
            }
            //用户进房间 并更新布局
            remotePlayer?.availible = available
            if available == true {
                self.trtc.startRemoteView(userId, view: remotePlayer?.player)
                self.trtc.setRemoteViewFillMode(userId, mode: .fill)
                trtcRoomView.layoutEngin.userAvailibleLayout(videoModel: remotePlayer!)
                
            }else{
                self.trtc.stopRemoteView(userId)
                trtcRoomView.layoutEngin.userLeaveLayout(videoModel: remotePlayer!)
            }
            
            remotePlayer?.player.showVideoCloseTip(show: !available)
            
        }else{
            localPlayModel?.player.showVideoCloseTip(show: !available)
        }
        
        //self.settingsManager.updateCloudMixtureParams()
    }
    
    /**
     * 4.1 网络质量，该回调每2秒触发一次，统计当前网络的上行和下行质量
     *
     * @note userId == nil 代表自己当前的视频质量
     *
     * @param localQuality 上行网络质量
     * @param remoteQuality 下行网络质量
     */
    func onNetworkQuality(_ localQuality: TRTCQualityInfo, remoteQuality: [TRTCQualityInfo]) {
        
        localPlayModel?.player.qualityInfo = localQuality
        localPlayModel?.player.updateNetworkIndicatorImage()
        
        for info in remoteQuality{
            let remotePlayer = trtcRoomView.layoutEngin.isInRoom(userId: info.userId!)
            remotePlayer?.player.qualityInfo = info
            remotePlayer?.player.updateNetworkIndicatorImage()
        }
    }

    /**
     * 7.3 收到 SEI 消息的回调
     *
     * 当房间中的某个用户使用 sendSEIMsg 发送数据时，房间中的其它用户可以通过 onRecvSEIMsg 接口接收数据。
     *
     * @param userId   用户标识
     * @param message  数据
     */
    func onRecvSEIMsg(_ userId: String, message: Data) {
        
    }
    
    /*
    * @param reason 离开房间原因，0：主动调用 exitRoom 退房；1：被服务器踢出当前房间；2：当前房间整个被解散。
    */
    func onExitRoom(_ reason: Int) {
        debugPrint("[退出房间] Reason:\(reason)")
    }
    
    /**
     * 1.1  错误回调，表示 SDK 不可恢复的错误，一定要监听并分情况给用户适当的界面提示。
     *
     * @param errCode 错误码
     * @param errMsg  错误信息
     * @param extInfo 扩展信息字段，个别错误码可能会带额外的信息帮助定位问题
     */
    func onError(_ errCode: TXLiteAVError, errMsg: String?, extInfo: [AnyHashable : Any]?) {
        debugPrint("发生严重错误:\(errMsg ?? " ")")
        
        let audioResumeError:Bool = ((errCode == ERR_MIC_START_FAIL) && (UIApplication.shared.applicationState != .active))
        if(!audioResumeError){
            let errorText = "发生严重错误:" + (errMsg ?? "未定义") + " \(errCode)"
            let alertVC  = UIAlertController.init(title: "已退房", message: errorText , preferredStyle: .alert)
            alertVC.addAction(UIAlertAction.init(title: "确定", style: .cancel, handler: { [weak self](action) in
                self?.trtcRoomView.backBtn.sendActions(for: .touchUpInside)
            }))
            alertVC.show(self, sender: nil)
        }
        
    }
}
