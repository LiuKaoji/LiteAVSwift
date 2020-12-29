//
//  LiveCaptureVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/4.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LiveCaptureVC: LiteAVBeautyBaseVC,TXLivePushListener {

    /// Live pusher
    lazy var pusher: TXLivePush = {
        let livePusher = self.setupLivePush()
        let config = livePusher.config
        config?.customModeType = CUSTOM_MODE_VIDEO_CAPTURE
        livePusher.config = config
        return livePusher
    }()
    
    /// Push url
    var pushURL:String?
    
    /// isPublish
    var isPublish: Bool = false
    
    /// 二维码
    lazy var qrCodeBtn :UIButton = {
        let btn = self.setuprRightBtn(imageName: "QR_code")
        return btn
    }()
    
    /// keys
    let qrKeys:Array<String> = ["url_play_rtmp","url_play_flv","url_play_hls","url_play_acc"]
    
    /// params
    var qrParams:Dictionary<String, String>?
    
    let asyncQueue = dispatch_queue_serial_t.init(label: "com.live.capture")
    
    override func viewDidLoad() {
        
        self.outputType = .sample
        
        super.viewDidLoad()

        self.titleLabel.text = "移动直播采集"
        
        qrCodeBtn.addTarget(self, action: #selector(onClickQrcode), for: .touchUpInside)
        
        requestLiveURLs()
    }
    
    override func onClickBack() {
        
        isPublish = false
        camera?.stopCapture()
        pusher.stopPreview()
        pusher.stop()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func beautyOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        pusher.sendVideoSampleBuffer(sampleBuffer)
    }
    
    
    /// 获取测试推拉流地址
    func requestLiveURLs(){
        
        LiveQRCodeVC.getURLs { [weak self] (pushURL, qrparams) in
            
            self?.pushURL = pushURL
            self?.qrParams = qrparams
            //self?.onClickQrcode()
            self?.startLiveStream()
            
        } retryCallback: { [weak self] in
            self?.retryAction()
        }
    }
    
    func startLiveStream(){
        isPublish = true
        pusher.delegate = self
        pusher.startPreview(nil)
        let code = pusher.start(self.pushURL)
        guard  code != 0 else {
            return
        }
        LiteAVMessageView.showMessage("启动推流失败", "错误码\(code)", .success)
    }
    
    func retryAction() {
        
        let errorText = "推拉流测试信息获取失败"
        let alertVC  = UIAlertController.init(title: nil, message: errorText , preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "重试", style: .destructive, handler: { [weak self](action) in
            self?.requestLiveURLs()
        }))
        alertVC.addAction(UIAlertAction.init(title: "退出", style: .cancel, handler: { [weak self](action) in
            self?.onClickBack()
        }))
        alertVC.show(self, sender: nil)
    }

    func onPushEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        
        asyncQueue.async { [self] in
            
            if (EvtID == PUSH_EVT_PUSH_BEGIN.rawValue) {
                
                showMessage(msg: "推流开始")
                
            } else if (EvtID == PUSH_ERR_NET_DISCONNECT.rawValue || EvtID == PUSH_ERR_INVALID_ADDRESS.rawValue) {

                showMessage(msg: "推流断开，请检查网络设置")
                
            } else if (EvtID == PUSH_ERR_OPEN_CAMERA_FAIL.rawValue) {

                showMessage(msg:"获取摄像头权限失败")
                
            } else if (EvtID == PUSH_ERR_OPEN_MIC_FAIL.rawValue) {
                
                showMessage(msg:"获取麦克风权限失败")
            }
        }
    }
    
    func showMessage(msg: String) {
        DispatchQueue.main.async {
            LiteAVMessageView.showMessage("onPushEvent", msg, .success)
        }
    }
    
    @objc func onClickQrcode() {
        
        guard qrParams != nil else {
            return
        }
        
        let qrView =  LiveQRCodeVC.init(keys: qrKeys, params: qrParams!)
        qrView.show(self)
    }
    
    func onNetStatus(_ param: [AnyHashable : Any]!) {}
    
    func onScreenCaptureStarted() {}
    
    func onScreenCapturePaused(_ reason: Int32) {}
    
    func onScreenCaptureResumed(_ reason: Int32) {}
    
    func onScreenCaptureStoped(_ reason: Int32) {}
}
