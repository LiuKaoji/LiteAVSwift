//
//  LiveTextureVC.swift
//  LiteAVSwift
//
//  Created by kaoji on 2020/12/21.
//  Copyright © 2020 kaoji. All rights reserved.
//

import UIKit

class LiveTextureVC: UIViewController,TXLivePushListener, TXVideoCustomProcessDelegate {
    
    /// 返回按钮
    lazy var backBtn = self.setupBackBtn()
    
    //标题
    lazy var titleView = self.setupTitleLabel()

    /// Live pusher
    lazy var pusher = self.setupLivePush()
    
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
    
    lazy var customFilter: TextureProcessor = {
        return TextureProcessor()
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        self.titleView.text = "预处理"
        
        backBtn.addTarget(self, action: #selector(onClickBack), for: .touchUpInside)
        qrCodeBtn.addTarget(self, action: #selector(onClickQrcode), for: .touchUpInside)
        
        requestLiveURLs()
    }
    
    @objc func onClickBack() {
        
        if isPublish {
            isPublish = false
            pusher.stop()
            pusher.stopPreview()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /// 预处理
    func onPreProcessTexture(_ texture: GLuint, width: CGFloat, height: CGFloat) -> GLuint {
        
        return self.customFilter.renderToTextureWithSize(.init(width: width, height: height), texture)
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
        pusher.videoProcessDelegate = self
        pusher.startPreview(self.view)
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
